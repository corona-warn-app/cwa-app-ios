//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class AllowListService {
	
	// MARK: - Init
	
	init(
	    restServiceProvider: RestServiceProviding
	) {
		self.restServiceProvider = restServiceProvider
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	
	// MARK: - Internal

	func fetchAllowList(completion: @escaping (Result<TicketValidationAllowList, AllowListError>) -> Void) {
		let resource = AllowListResource()
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let allowListProtoBuf):
				Log.debug("Allow List received", log: .ticketValidationAllowList)
				completion(.success(allowListProtoBuf.allowlist))
				return
			case .failure(let error):
				Log.debug(error.localizedDescription, log: .ticketValidationAllowList)
				completion(.failure(.REST_SERVICE_ERROR(error)))
			}
		}
	}
	
	func checkServiceIdentityAgainstServiceProviderAllowlist(
		serviceProviderAllowlist: [Data],
		serviceIdentity: String
	) -> Result<Void, AllowListError> {
		let base64EncodedServiceIdentityHash = Data(hex: serviceIdentity.sha256()).base64EncodedString()
		if serviceProviderAllowlist.contains(where: {
			$0.base64EncodedString() == base64EncodedServiceIdentityHash
		}) {
			return .success(())
		} else {
			return .failure(.SP_ALLOWLIST_NO_MATCH)
		}
	}
	
	func filterJWKsAgainstAllowList(allowList: [ValidationServiceAllowlistEntry], jwkSet: [JSONWebKey]) -> Result<Void, AllowListError> {
		
		var filteredAllowList = [ValidationServiceAllowlistEntry]()
		let filteredJwkSet = jwkSet.filter({
			guard let x509String = $0.x5c.first, let x509Data = Data(base64Encoded: x509String) else {
				return false
			}
			
			return allowList.contains { entry in
				if entry.fingerprint256 == x509Data.sha256().base64EncodedString() {
					filteredAllowList.append(entry)
					return true
				} else {
					return false
				}
			}
		})
		if filteredJwkSet.isEmpty {
			return .failure(.SP_ALLOWLIST_NO_MATCH)
		} else {
			return .success(())
		}
	}
}
