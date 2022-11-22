//
// 🦠 Corona-Warn-App
//

import Foundation

class MockSRSService: SRSServiceProviding {
	func authenticate(completion: @escaping SRSAuthenticationResponse) {
		completion(.success("TEST"))
	}
	
	
}
