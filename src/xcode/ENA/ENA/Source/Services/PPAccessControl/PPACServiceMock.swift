//
// 🦠 Corona-Warn-App
//

import Foundation

class PPACServiceMock: PPACService {
	static let ppacTokenMock = PPACToken(apiToken: "api-token-mock", previousApiToken: "previous-api-token-mock", deviceToken: "device-token-mock")

	override func getPPACTokenEDUS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		completion(.success(Self.ppacTokenMock))
	}
	
	override func getPPACTokenELS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		completion(.success(Self.ppacTokenMock))
	}
	
	override func getPPACTokenSRS(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		completion(.success(Self.ppacTokenMock))
	}
	
	override func checkSRSFlowPrerequisites(
		minTimeSinceOnboardingInHours: Int,
		minTimeBetweenSubmissionsInDays: Int,
		completion: @escaping (Result<Void, SRSPreconditionError>) -> Void
	) {
		completion(.success(()))
	}
}
