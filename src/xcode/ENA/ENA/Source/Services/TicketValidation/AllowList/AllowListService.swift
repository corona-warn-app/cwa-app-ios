//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
import OpenCombine

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

	@OpenCombine.Published var allowlist: TicketValidationAllowList?

	func fetchAllowList() {
		let resource = AllowListResource()
		restServiceProvider.load(resource) { [weak self] result in
			switch result {
			case .success(let allowListProtoBuf):
				self?.allowlist = allowListProtoBuf.allowlist
			case .failure(let error):
				Log.debug(error.localizedDescription, log: .ticketValidationAllowList)
			}
		}
	}
	
	func checkServiceIdentityAgainstServiceProviderAllowlist(
		serviceProviderAllowlist: [Data],
		serviceIdentity: String
	) -> Result<Void, AllowListError> {
		
		if serviceProviderAllowlist.contains(where: {
			$0.sha256().base64EncodedString() == serviceIdentity.sha256()
		}) {
			return .success(())
		} else {
			return .failure(.SP_ALLOWLIST_NO_MATCH)
		}
	}
	
	func filterJWKsAgainstAllowList(allowList: [ValidationServiceAllowlistEntry], jwkSet: [JSONWebKey]) -> ([ValidationServiceAllowlistEntry], [JSONWebKey]) {
		
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
		
		return (filteredAllowList, filteredJwkSet)
	}
}
