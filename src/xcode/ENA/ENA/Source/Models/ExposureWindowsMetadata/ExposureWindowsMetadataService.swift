////
// 🦠 Corona-Warn-App
//

import Foundation

class ExposureWindowsMetadataService {
	
	// MARK: - Internal

	func collectExposureWindows(from riskCalculation: RiskCalculationProtocol, store: Store) {
		guard let calculation = riskCalculation as? RiskCalculation else {
			Log.debug("Instance of riskCalculation couldn't be casted into RiskCalculation type", log: .ppa)
			return
		}
		self.clearReportedExposureWindowsQueueIfNeeded(store: store)
		
		let mappedSubmittionExposureWindows: [SubmittionExposureWindow] = calculation.mappedExposureWindows.map {
			SubmittionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: self.convertToData($0.exposureWindow)?.sha256String(),
				date: $0.date
			)
		}
		
		if store.exposureWindowsMetadata != nil {
			// if store is initialized:
			// - Queue if new: if the hash of the Exposure Window not included in reportedExposureWindowsQueue, the Exposure Window is added to reportedExposureWindowsQueue.
			for exposureWindow in mappedSubmittionExposureWindows {
				if store.exposureWindowsMetadata?.reportedExposureWindowsQueue.first(where: { $0.hash == exposureWindow.hash }) == nil {
					store.exposureWindowsMetadata?.newExposureWindowsQueue.append(exposureWindow)
					store.exposureWindowsMetadata?.reportedExposureWindowsQueue.append(exposureWindow)
				}
			}
		} else {
			// if store is not initialized:
			// - Initialize and add all of the exposure windows to both "newExposureWindowsQueue" and "reportedExposureWindowsQueue" arrays
			store.exposureWindowsMetadata = ExposureWindowsMetadata(
				newExposureWindowsQueue: mappedSubmittionExposureWindows,
				reportedExposureWindowsQueue: mappedSubmittionExposureWindows
			)
		}
	}
	
	// MARK: - Private

	private func clearReportedExposureWindowsQueueIfNeeded(store: Store) {
		if let NonExpiredWindows = store.exposureWindowsMetadata?.reportedExposureWindowsQueue.filter({
			guard let day = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day else {
				Log.debug("Exposure Window is removed from reportedExposureWindowsQueue as the date componant is nil", log: .ppa)
				return false
			}
			return day < 15
		}) {
			store.exposureWindowsMetadata?.reportedExposureWindowsQueue = NonExpiredWindows
		}
	}
	
	private func convertToData(_ window: ExposureWindow) -> Data? {
		var windowData: Data?
		
		do {
			let encoder = JSONEncoder()
			windowData = try encoder.encode(window)

		} catch {
			Log.error("ExposureWindow Encoding error", log: .ppa, error: error)
		}
		return windowData
	}
}
