////
// 🦠 Corona-Warn-App
//

import Foundation

protocol PrivacyPreservingAccessControl {
	func getPPACTokenEDUS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void)
	func getPPACTokenELS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void)
	func getPPACTokenSRS(
		timeSinceOnboardingInHours: Int,
		timeBetweenSubmissionsInDays: Int,
		completion: @escaping (Result<PPACToken, PPACError>) -> Void
	)
	#if !RELEASE
	func generateNewAPIEdusToken() -> TimestampedToken
	func generateNewAPIElsToken() -> TimestampedToken
	#endif
}

class PPACService: PrivacyPreservingAccessControl {

	// MARK: - Init

	init(
		store: Store,
		deviceCheck: DeviceCheckable
	) {
		self.store = store
		self.deviceCheck = deviceCheck
	}

	// MARK: - Protocol PrivacyPreservingAccessControl

	func getPPACTokenSRS(
		timeSinceOnboardingInHours: Int,
		timeBetweenSubmissionsInDays: Int,
		completion: @escaping (Result<PPACToken, PPACError>) -> Void
	) {

		// check if time isn't incorrect
		if store.deviceTimeCheckResult == .incorrect {
			Log.error("SRSError: device time is incorrect", log: .ppac)
			completion(.failure(PPACError.timeIncorrect))
			return
		}

		// check if time isn't unknown
		if store.deviceTimeCheckResult == .assumedCorrect {
			Log.error("SRSError:device time is unverified", log: .ppac)
			completion(.failure(PPACError.timeUnverified))
			return
		}
		
		// Check FIRST_RELIABLE_TIMESTAMP
		if let firstReliableTimeStamp = store.firstReliableTimeStamp,
		   let difference = Calendar.current.dateComponents([.hour], from: firstReliableTimeStamp, to: Date()).hour {
			let timeSinceOnboarding = timeSinceOnboardingInHours <= 0 ? 24 : timeSinceOnboardingInHours
			Log.debug("actual time since onboarding \(timeSinceOnboardingInHours) hours.", log: .ppac)
			
			if difference < timeSinceOnboarding {
				Log.error("SRSError:too short time since onboarding", log: .ppac)
				completion(.failure(PPACError.minimumTimeSinceOnboarding))
				return
			}
		}
		
		// Check time since previous submission
		if let mostRecentKeySubmissionDate = store.mostRecentKeySubmissionDate,
		   let difference = Calendar.current.dateComponents([.day], from: mostRecentKeySubmissionDate, to: Date()).day {
			let timeBetweenSubmissions = timeBetweenSubmissionsInDays <= 0 ? 90 : timeBetweenSubmissionsInDays
			Log.debug("timeBetweenSubmissionsInDays = \(timeSinceOnboardingInHours) days.", log: .ppac)
			
			if difference < timeBetweenSubmissions {
				Log.error("SRSError: submission too early", log: .ppac)
				completion(.failure(PPACError.submissionTooEarly))
				return
			}
		}
		
		deviceCheck.deviceToken(apiTokenSRS.token, completion: completion)
	}

	func getPPACTokenEDUS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {

		// check if time isn't incorrect
		if store.deviceTimeCheckResult == .incorrect {
			Log.error("device time is incorrect", log: .ppac)
			completion(.failure(PPACError.timeIncorrect))
			return
		}

		// check if time isn't unknown
		if store.deviceTimeCheckResult == .assumedCorrect {
			Log.error("device time is unverified", log: .ppac)
			completion(.failure(PPACError.timeUnverified))
			return
		}

		// check if device supports DeviceCheck
		guard deviceCheck.isSupported else {
			Log.error("device token not supported", log: .ppac)
			completion(.failure(PPACError.deviceNotSupported))
			return
		}

		deviceCheck.deviceToken(apiTokenEDUS.token, completion: completion)
	}
	
	func getPPACTokenELS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		// no device time checks for ELS
		deviceCheck.deviceToken(apiTokenELS.token, completion: completion)
	}

	#if !RELEASE
	// needed to make it possible to get called from the developer menu
	func generateNewAPIEdusToken() -> TimestampedToken {
		let token = generateAndStoreFreshAPIToken()
		store.ppacApiTokenEdus = token
		return token
	}
	
	func generateNewAPIElsToken() -> TimestampedToken {
		let token = generateAndStoreFreshAPIToken()
		store.ppacApiTokenEls = token
		return token
	}
	#endif

	// MARK: - Private

	private let deviceCheck: DeviceCheckable
	private let store: Store

	/// will return the current API Token and create a new one if needed
	private var apiTokenEDUS: TimestampedToken {
		let today = Date()
		/// check if we already have a token and if it was created in this month / year
		guard let storedToken = store.ppacApiTokenEdus,
			  storedToken.timestamp.isEqual(to: today, toGranularity: .month),
			  storedToken.timestamp.isEqual(to: today, toGranularity: .year)
		else {
			let newToken = generateAndStoreFreshAPIToken()
			store.ppacApiTokenEdus = newToken
			return newToken
		}
		return storedToken
	}
	
	private var apiTokenELS: TimestampedToken {
		guard let storedToken = store.ppacApiTokenEls
		else {
			let newToken = generateAndStoreFreshAPIToken()
			store.ppacApiTokenEls = newToken
			return newToken
		}
		return storedToken
	}

	private var apiTokenSRS: TimestampedToken {
		guard let storedToken = store.ppacApiTokenSRS
		else {
			let newToken = generateAndStoreFreshAPIToken()
			store.ppacApiTokenEls = newToken
			return newToken
		}
		return storedToken
	}

	/// generate a new API Token and store it
	private func generateAndStoreFreshAPIToken() -> TimestampedToken {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)

		Log.info("Generated new API token", log: .ppac)
		return token
	}
}
