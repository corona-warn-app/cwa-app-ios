////
// 🦠 Corona-Warn-App
//

import Foundation

class ExposureWindowsMetadataService {
	
	// MARK: - Internal

	func collectExposureWindows(from riskCalculation: RiskCalculationProtocol, store: Store) {
		self.clearReportedExposureWindowsQueueIfNeeded(store: store)
		
		let mappedSubmissionExposureWindows: [SubmissionExposureWindow] = riskCalculation.mappedExposureWindows.map {
			SubmissionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: generateSHA256($0.exposureWindow),
				date: $0.date
			)
		}
		
		if let metadata = store.exposureWindowsMetadata {
			// if store is initialized:
			// - Queue if new: if the hash of the Exposure Window not included in reportedExposureWindowsQueue, the Exposure Window is added to reportedExposureWindowsQueue.
			for exposureWindow in mappedSubmissionExposureWindows {
				if !metadata.reportedExposureWindowsQueue.contains(where: { $0.hash == exposureWindow.hash }) {
					store.exposureWindowsMetadata?.newExposureWindowsQueue.append(exposureWindow)
					store.exposureWindowsMetadata?.reportedExposureWindowsQueue.append(exposureWindow)
				}
			}
		} else {
			// if store is not initialized:
			// - Initialize and add all of the exposure windows to both "newExposureWindowsQueue" and "reportedExposureWindowsQueue" arrays
			store.exposureWindowsMetadata = ExposureWindowsMetadata(
				newExposureWindowsQueue: mappedSubmissionExposureWindows,
				reportedExposureWindowsQueue: mappedSubmissionExposureWindows
			)
		}
	}
	
	// MARK: - Private

	private func clearReportedExposureWindowsQueueIfNeeded(store: Store) {
		if let nonExpiredWindows = store.exposureWindowsMetadata?.reportedExposureWindowsQueue.filter({
			guard let day = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day else {
				Log.debug("Exposure Window is removed from reportedExposureWindowsQueue as the date component is nil", log: .ppa)
				return false
			}
			return day < 15
		}) {
			store.exposureWindowsMetadata?.reportedExposureWindowsQueue = nonExpiredWindows
		}
	}
	private func generateSHA256(_ window: ExposureWindow) -> String? {
		let encoder = JSONEncoder()
		do {
			let windowData = try encoder.encode(window)
			return windowData.sha256String()
		} catch {
			Log.error("ExposureWindow Encoding error", log: .ppa, error: error)
		}
		return nil
	}
}
