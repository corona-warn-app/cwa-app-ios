////
// 🦠 Corona-Warn-App
//

@testable import ENA

struct MockVerifier: SignatureVerification {
	
	// MARK: - Protocol Verify
	
	func verify(_ package: SAPDownloadedPackage) -> Bool {
		return true
	}
}
