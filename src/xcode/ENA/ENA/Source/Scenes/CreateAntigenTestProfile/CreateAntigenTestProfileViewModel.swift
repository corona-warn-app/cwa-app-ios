////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class CreateAntigenTestProfileViewModel {

	// MARK: - Init
	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
		self.antigenTestProfile = AntigenTestProfile()
	}

	// MARK: - Internal
	@OpenCombine.Published var antigenTestProfile: AntigenTestProfile

	func save() {
		store.antigenTestProfile = antigenTestProfile
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring

}
