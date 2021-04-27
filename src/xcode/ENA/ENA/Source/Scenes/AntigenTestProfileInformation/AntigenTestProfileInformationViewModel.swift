////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTestProfileInformationViewModel {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let title: String = "Schnelltest-Profil"

	func markScreenSeen() {
		store.antigenTestProfileInfoScreenShown = true
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring

}
