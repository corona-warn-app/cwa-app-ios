//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class MockRevocationProvider: RevocationProviding {

	// MARK: - Protocol RevocationProviding

	func updateCache(with certificates: [HealthCertificate], completion: @escaping (Result<[HealthCertificate], RevocationProviderError>) -> Void) {
		completion(updateCacheResult)
	}

	func isRevokedFromRevocationList(healthCertificate: HealthCertificate) -> Bool {
		switch updateCacheResult {
		case .success(let healthCertificates):
			return healthCertificates.contains(healthCertificate)
		case .failure:
			return false
		}
	}

	// MARK: - Internal

	var updateCacheResult: Result<[HealthCertificate], RevocationProviderError> = .success([])

}
