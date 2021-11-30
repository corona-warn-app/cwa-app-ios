//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class AllowListService {
	
	// MARK: - Init
	
	init(restServiceProvider: RestServiceProviding, store: Store) {
		self.restServiceProvider = restServiceProvider
		self.store = store
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let store: Store
	
	// MARK: - Internal

	func fetchAllowList() {
		let resource = AllowListResource()
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let allowList):
				let serviceProviderAllowlist = allowList.serviceProviders.map({
					$0.serviceIdentityHash
				})
				let validationServiceAllowlist = allowList.certificates.map({
					ValidationServiceAllowlistEntry(
						serviceProvider: $0.serviceProvider,
						hostname: $0.hostname,
						fingerprint256: $0.fingerprint256.base64EncodedString()
					)
				})
				self.store.ticketValidationAllowList = TicketValidationAllowList(
					validationServiceAllowList: validationServiceAllowlist,
					serviceProviderAllowList: serviceProviderAllowlist
				)
				
			case .failure(let error):
				Log.debug(error.localizedDescription)
			}
		}
	}
}
