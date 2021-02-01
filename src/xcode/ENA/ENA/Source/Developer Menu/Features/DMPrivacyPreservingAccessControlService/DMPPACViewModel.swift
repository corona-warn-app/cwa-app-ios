////
// 🦠 Corona-Warn-App
//

import Foundation

final class DMPPCViewModel {

	// MARK: - Init

	init(_ store: Store, deviceCheck: DeviceCheckable) {
		do {
			self.ppacService = try? PPACService(store: store, deviceCheck: deviceCheck)
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let ppacService: PrivacyPreservingAccessControl?

}
