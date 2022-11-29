//
// 🦠 Corona-Warn-App
//

import Foundation

class MockSRSService: SRSServiceProviding {
	func checkSRSFlowPrerequisites(completion: @escaping SRSPerquisiteChecksResponse) {
		completion(.success(()))
	}

	func authenticate(completion: @escaping SRSAuthenticationResponse) {
		completion(.success("TEST"))
	}
}
