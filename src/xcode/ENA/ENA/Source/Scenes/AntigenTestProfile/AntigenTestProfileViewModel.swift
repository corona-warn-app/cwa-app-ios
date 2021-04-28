////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTestProfileViewModel {

	// MARK: - Init
	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
		self.antigenTestProfile = store.antigenTestProfile
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func deleteProfile() {
		store.antigenTestProfile = nil
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring
	private var antigenTestProfile: AntigenTestProfile?
}
