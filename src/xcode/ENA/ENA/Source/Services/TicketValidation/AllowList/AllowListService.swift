//
// 🦠 Corona-Warn-App
//

import Foundation

final class AllowListService {
	
	// MARK: - Init
	
	init(restServiceProvider: RestServiceProviding, store: Store) {
		self.restServiceProvider = restServiceProvider
		self.store = store
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let store: Store
}
