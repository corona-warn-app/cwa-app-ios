// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ExposureNotification
import Foundation

/// Every time the user wants to know the own risk the app creates an `ExposureDetection`.
final class ExposureDetection {

	// MARK: Properties
	@Published var activityState: RiskProvider.ActivityState = .idle
	private weak var delegate: ExposureDetectionDelegate?
	private var completion: Completion?
	private var progress: Progress?
	private let appConfiguration: SAP_Internal_ApplicationConfiguration
	private let deviceTimeCheck: DeviceTimeCheckProtocol

	// There was a decision not to use the 2 letter code "EU", but instead "EUR".
	// Please see this story for more informations: https://jira.itc.sap.com/browse/EXPOSUREBACK-151
	private let country = "EUR"

	// MARK: Creating a Transaction
	init(
		delegate: ExposureDetectionDelegate,
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		deviceTimeCheck: DeviceTimeCheckProtocol
	) {
		self.delegate = delegate
		self.appConfiguration = appConfiguration
		self.deviceTimeCheck = deviceTimeCheck
	}

	func cancel() {
		activityState = .idle
		progress?.cancel()
	}

	private func writeKeyPackagesToFileSystem(completion: (WrittenPackages) -> Void) {
		if let writtenPackages = self.delegate?.exposureDetectionWriteDownloadedPackages(country: country) {
			completion(WrittenPackages(urls: writtenPackages.urls))
		} else {
			endPrematurely(reason: .unableToWriteDiagnosisKeys)
		}
	}

	private var exposureConfiguration: ENExposureConfiguration? {
		guard let configuration = try? ENExposureConfiguration(from: appConfiguration.exposureConfig, minRiskScore: appConfiguration.minRiskScore) else {
			return nil
		}

		return configuration
	}

	private func detectSummary(writtenPackages: WrittenPackages, exposureConfiguration: ENExposureConfiguration) {
		self.progress = self.delegate?.exposureDetection(
			self,
			detectSummaryWithConfiguration: exposureConfiguration,
			writtenPackages: writtenPackages
		) { [weak self] result in
			writtenPackages.cleanUp()
			self?.useSummaryResult(result)
		}
	}

	private func useSummaryResult(_ result: Result<ENExposureDetectionSummary, Error>) {
		switch result {
		case .success(let summary):
			didDetectSummary(summary)
		case .failure(let error):
			endPrematurely(reason: .noSummary(error))
		}
	}

	typealias Completion = (Result<ENExposureDetectionSummary, DidEndPrematurelyReason>) -> Void

    func start(completion: @escaping Completion) {
        Log.info("ExposureDetection: Start downloading packages.", log: .riskDetection)

        self.completion = completion

        Log.info("ExposureDetection: Completed downloading packages.", log: .riskDetection)
        Log.info("ExposureDetection: Start writing packages to file system.", log: .riskDetection)

        self.activityState = .detecting

        self.writeKeyPackagesToFileSystem { [weak self] writtenPackages in
            guard let self = self else { return }

            Log.info("ExposureDetection: Completed writing packages to file system.", log: .riskDetection)

            if let exposureConfiguration = self.exposureConfiguration {
                if !self.deviceTimeCheck.isDeviceTimeCorrect {
                    Log.warning("ExposureDetection: Detecting summary skipped due to wrong device time.", log: .riskDetection)
                    self.endPrematurely(reason: .wrongDeviceTime)
                } else {
                    Log.info("ExposureDetection: Start detecting summary.", log: .riskDetection)
                    self.detectSummary(writtenPackages: writtenPackages, exposureConfiguration: exposureConfiguration)
                }
            } else {
                Log.error("ExposureDetection: End prematurely.", log: .riskDetection, error: DidEndPrematurelyReason.noExposureConfiguration)

                self.endPrematurely(reason: .noExposureConfiguration)
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

		activityState = .idle

		DispatchQueue.main.async {
			self.completion?(.failure(reason))
			self.completion = nil
		}
	}

	// Informs the delegate about a summary.
	private func didDetectSummary(_ summary: ENExposureDetectionSummary) {
		Log.info("ExposureDetection: Completed detecting summary.", log: .riskDetection)

		precondition(
			completion != nil,
			"Tried report a summary but no completion handler is set."
		)

		activityState = .idle

		DispatchQueue.main.async {
			self.completion?(.success(summary))
			self.completion = nil
		}
	}
}

private extension ENExposureConfiguration {
	convenience init(from riskscoreParameters: SAP_Internal_RiskScoreParameters, minRiskScore: Int32) throws {
		self.init()
		minimumRiskScore = UInt8(clamping: minRiskScore)
		minimumRiskScoreFullRange = Double(minRiskScore)
		attenuationLevelValues = riskscoreParameters.attenuation.asArray
		daysSinceLastExposureLevelValues = riskscoreParameters.daysSinceLastExposure.asArray
		durationLevelValues = riskscoreParameters.duration.asArray
		transmissionRiskLevelValues = riskscoreParameters.transmission.asArray
	}
}

private extension SAP_Internal_RiskLevel {
	var asNumber: NSNumber {
		NSNumber(value: rawValue)
	}
}

private extension SAP_Internal_RiskScoreParameters.TransmissionRiskParameters {
	var asArray: [NSNumber] {
		[appDefined1, appDefined2, appDefined3, appDefined4, appDefined5, appDefined6, appDefined7, appDefined8].map { $0.asNumber }
	}
}

private extension SAP_Internal_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
	var asArray: [NSNumber] {
		[ge14Days, ge12Lt14Days, ge10Lt12Days, ge8Lt10Days, ge6Lt8Days, ge4Lt6Days, ge2Lt4Days, ge0Lt2Days].map { $0.asNumber }
	}
}

private extension SAP_Internal_RiskScoreParameters.DurationRiskParameters {
	var asArray: [NSNumber] {
		[eq0Min, gt0Le5Min, gt5Le10Min, gt10Le15Min, gt15Le20Min, gt20Le25Min, gt25Le30Min, gt30Min].map { $0.asNumber }
	}
}

private extension SAP_Internal_RiskScoreParameters.AttenuationRiskParameters {
	var asArray: [NSNumber] {
		[gt73Dbm, gt63Le73Dbm, gt51Le63Dbm, gt33Le51Dbm, gt27Le33Dbm, gt15Le27Dbm, gt10Le15Dbm, le10Dbm].map { $0.asNumber }
	}
}
