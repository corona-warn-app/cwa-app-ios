////
// 🦠 Corona-Warn-App
//

@testable import ENA

struct MockVerifier: Verify {

	// MARK: - Init
	
	// MARK: - Overrides
	
	// MARK: - Protocol Verify
	
	func verify(_ package: SAPDownloadedPackage) -> Bool {
		return true
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
}
