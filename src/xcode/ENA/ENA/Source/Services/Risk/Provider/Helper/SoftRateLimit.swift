////
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification


class SoftRateLimit {
	
	// MARK: - Init

	init(
		store: Store,
		logger: Logging? = nil
	) {
		self.store = store
		self.logger = logger
	}

	// MARK: - Internal
	func setup(configuration: RiskProvidingConfiguration) -> Bool {
		let enoughTimeHasPassed = configuration.shouldPerformExposureDetection(
			lastExposureDetectionDate: store.exposureDetectionDate, context: " for soft rate limit"
		)
		let blocking = !enoughTimeHasPassed
		if blocking {
			Log.info("Soft rate limit is stricter than effective rate limit", log: .riskDetection, logger: logger)
		} else {
			Log.debug("Soft rate limit is in synch with effective rate limit", log: .riskDetection, logger: logger)
		}
		return blocking
	}

	func assess(
		result: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason>,
		blocking: Bool
	) {
		switch result {
		case .success:
			if blocking {
				Log.warning("Soft rate limit is too strict - it would have blocked this successfull exposure detection", log: .riskDetection, logger: logger)
			}
			previousErrorCode = nil
		case .failure(let failure):
			switch failure {
			case .noExposureWindows(let error):
				if let enError = error as? ENError {
					if enError.code == .rateLimited {
						let str1 = blocking ? "" : " NOT"
						Log.info("Soft rate limit would\(str1) have prevented this \(description(reason: failure))", log: .riskDetection, logger: logger)
						if let prevCode = previousErrorCode {
							Log.info("Previous ENError code = \(prevCode.rawValue)", log: .riskDetection, logger: logger)
						} else {
							Log.info("Previous call to ENF was successful", log: .riskDetection, logger: logger)
						}
						return
					} else {
						previousErrorCode = enError.code
					}
				}
			default:
				break
			}
			if blocking {
				Log.warning("Soft rate limit is too strict - it would have blocked this exposure detection with \(description(reason: failure))", log: .riskDetection, logger: logger)
			}
		}
	}
		
	func description(reason: ExposureDetection.DidEndPrematurelyReason) -> String {
		switch reason {
		case .noExposureWindows(let error):
			if let enError = error as? ENError {
				return "ENError \(enError.code.rawValue)"
			} else {
				return "error"
			}
		default:
			return "failure"
		}
	}
	
	var previousErrorCode: ENError.Code?
	private let store: Store
	private var logger: Logging?
}
