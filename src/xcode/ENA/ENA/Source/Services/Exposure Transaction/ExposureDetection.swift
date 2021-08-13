//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation

/// Every time the user wants to know the own risk the app creates an `ExposureDetection`.
final class ExposureDetection {

	// MARK: Properties
	private weak var delegate: ExposureDetectionDelegate?
	private var completion: Completion?
	private var progress: Progress?
	private let appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS
	private let deviceTimeCheck: DeviceTimeChecking

	// There was a decision not to use the 2 letter code "EU", but instead "EUR".
	// Please see this story for more informations: https://jira.itc.sap.com/browse/EXPOSUREBACK-151
	private let country = "EUR"

	// MARK: Creating a Transaction
	init(
		delegate: ExposureDetectionDelegate,
		appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		deviceTimeCheck: DeviceTimeChecking
	) {
		self.delegate = delegate
		self.appConfiguration = appConfiguration
		self.deviceTimeCheck = deviceTimeCheck
	}

	func cancel() {
		progress?.cancel()
	}

	private func writeKeyPackagesToFileSystem(completion: (WrittenPackages) -> Void) {
		if let writtenPackages = self.delegate?.exposureDetectionWriteDownloadedPackages(country: country) {
			completion(writtenPackages)
		} else {
			endPrematurely(reason: .unableToWriteDiagnosisKeys)
		}
	}

	private func detectExposureWindows(writtenPackages: WrittenPackages, exposureConfiguration: ENExposureConfiguration) {
		if progress != nil {
			Log.error("previous running progress found, will try to cancel", log: .riskDetection)
			progress?.cancel()
		}
		progress = delegate?.detectExposureWindows(
			self,
			detectSummaryWithConfiguration: exposureConfiguration,
			writtenPackages: writtenPackages
		) { [weak self] result in
			writtenPackages.cleanUp()
			self?.useExposureWindowsResult(result)
		}
	}

	private func useExposureWindowsResult(_ result: Result<[ENExposureWindow], Error>) {
		switch result {
		case .success(let exposureWindows):
			didDetectExposureWindows(exposureWindows)
		case .failure(let error):
			endPrematurely(reason: .noExposureWindows(error))
		}
	}

	typealias Completion = (Result<[ENExposureWindow], DidEndPrematurelyReason>) -> Void

    func start(completion: @escaping Completion) {
        self.completion = completion

        Log.info("ExposureDetection: Start writing packages to file system.", log: .riskDetection)

        writeKeyPackagesToFileSystem { [weak self] writtenPackages in
            guard let self = self else { return }

            Log.info("ExposureDetection: Completed writing packages to file system.", log: .riskDetection)

			if !self.deviceTimeCheck.isDeviceTimeCorrect {
				Log.warning("ExposureDetection: Detecting exposure windows skipped due to wrong device time.", log: .riskDetection)
				self.endPrematurely(reason: .wrongDeviceTime)
			} else {
				Log.info("ExposureDetection: Start detecting exposure windows.", log: .riskDetection)
				let exposureConfiguration = ENExposureConfiguration(from: appConfiguration.exposureConfiguration)
				self.detectExposureWindows(writtenPackages: writtenPackages, exposureConfiguration: exposureConfiguration)
			}
        }
    }
	
	// MARK: Working with the Completion Handler

	// Ends the transaction prematurely with a given reason.
	private func endPrematurely(reason: DidEndPrematurelyReason) {
		Log.error("ExposureDetection: End prematurely.", log: .riskDetection, error: reason)

		precondition(
			completion != nil,
			"Tried to end a detection prematurely is only possible if a detection is currently running."
		)

		DispatchQueue.main.async {
			self.completion?(.failure(reason))
			self.completion = nil
		}
	}

	// Informs the delegate about the detected exposure windows.
	private func didDetectExposureWindows(_ exposureWindows: [ENExposureWindow]) {
		Log.info("ExposureDetection: Completed detecting exposure windows.", log: .riskDetection)

		precondition(
			completion != nil,
			"Tried report exposure windows but no completion handler is set."
		)
		
		DispatchQueue.main.async {
			self.completion?(.success(exposureWindows))
			self.completion = nil
		}
	}

}
