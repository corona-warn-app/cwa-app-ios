////
// 🦠 Corona-Warn-App
//

import Foundation

final class DMPPCViewModel {

	// MARK: - Init

	init(_ store: Store) {
		do {
			self.ppacService = try? PrivacyPreservingAccessControlService(store: store)
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let ppacService: PrivacyPreservingAccessControl?

}
