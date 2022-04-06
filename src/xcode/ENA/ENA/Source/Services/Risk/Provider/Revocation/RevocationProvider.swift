//
// 🦠 Corona-Warn-App
//

import Foundation

protocol RevocationProviding {

	func updateCache(with certificates: [HealthCertificate]) -> Result<Void, RevocationServiceError>

}

enum RevocationServiceError: LocalizedError {
	case DCC_RL_KID_LIST_SERVER_ERROR
	case DCC_RL_KID_LIST_CLIENT_ERROR
	case DCC_RL_KID_LIST_NO_NETWORK
	case DCC_RL_KID_LIST_INVALID_SIGNATURE
	case DCC_RL_KT_IDX_SERVER_ERROR
	case DCC_RL_KT_IDX_CLIENT_ERROR
	case DCC_RL_KT_IDX_NO_NETWORK
	case DCC_RL_KT_IDX_INVALID_SIGNATURE
	case DCC_RL_KTXY_CHUNK_SERVER_ERROR
	case DCC_RL_KTXY_CHUNK_CLIENT_ERROR
	case DCC_RL_KTXY_CHUNK_NO_NETWORK
	case DCC_RL_KTXY_INVALID_SIGNATURE
	case internalError
}

final class RevocationProvider: RevocationProviding {

	// MARK: - Init

	init(
		_ restService: RestServiceProvider
	) {
		self.restService = restService
	}

	// MARK: - Overrides

	// MARK: - Protocol RevocationProviding

	func updateCache(with certificates: [HealthCertificate]) -> Result<Void, RevocationServiceError> {
		// 1. Filter by certificate type
		let filteredCertificates = certificates.filter { certificate in
			(certificate.type == .vaccination ||
			certificate.type == .recovery) &&
			certificate.keyIdentifier != nil
		}

		// 2. group certificates by kid
		let groupedCertificates = Dictionary(grouping: filteredCertificates) { element in
			element.keyIdentifier
		}


		return Result.success(())
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let restService: RestServiceProvider
	private let queue: DispatchQueue = DispatchQueue(label: "RevocationServiceQueue")

	/// write to store
	private var lastExecution: Date = Date()

}
