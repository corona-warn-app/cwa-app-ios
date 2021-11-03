////
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification


class RateLimitLogger {
	
	// MARK: - Init

	init(
		store: Store,
		logger: Logging? = nil
	) {
		self.store = store
		self.logger = logger
	}

	// MARK: - Internal
	
	var previousErrorCode: ENError.Code?
	
	func logBlocking(configuration: RiskProvidingConfiguration) -> Bool {
		let enoughTimeHasPassed = configuration.shouldPerformExposureDetection(
			lastExposureDetectionDate: store.referenceDateForRateLimitLogger, context: .rateLimitLogger
		)
		if enoughTimeHasPassed {
			Log.debug("Soft rate limit is in synch with effective rate limit", log: .riskDetection, logger: logger)
		} else {
			Log.info("Soft rate limit is stricter than effective rate limit", log: .riskDetection, logger: logger)
		}
		return !enoughTimeHasPassed
	}

	func logEffect(
		result: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason>,
		blocking: Bool
	) {
		switch result {
		case .success:
			if blocking {
				Log.warning("Soft rate limit is too strict - it would have blocked this successful exposure detection", log: .riskDetection, logger: logger)
			}
			previousErrorCode = nil
		case let .failure(failure):
			switch failure {
			case let .noExposureWindows(error as ENError, _):
				guard error.code != .rateLimited else {
					let qualifier = blocking ? "" : " NOT"
					Log.info("Soft rate limit would\(qualifier) have prevented this \(description(reason: failure))", log: .riskDetection, logger: logger)
					if let prevCode = previousErrorCode {
						Log.info("Previous ENError code = \(prevCode.rawValue)", log: .riskDetection, logger: logger)
					} else {
						Log.info("Previous call to ENF was successful", log: .riskDetection, logger: logger)
					}
					return
				}
				previousErrorCode = error.code
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
		case .noExposureWindows(let error, _):
			if let enError = error as? ENError {
				return "ENError \(enError.code.rawValue)"
			} else {
				return "error"
			}
		default:
			return "failure"
		}
	}
	
	// MARK: - Private

	private let store: Store
	private var logger: Logging?
}
