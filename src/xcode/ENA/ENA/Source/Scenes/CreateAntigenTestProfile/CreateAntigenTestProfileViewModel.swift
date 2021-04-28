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

		// this is only for coordinator testing, remove later
		antigenTestProfile.firstName = "Max"
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal
	@OpenCombine.Published var antigenTestProfile: AntigenTestProfile

	let title: String = "Schnelltest-Profil"

	var isSaveButtonEnabled: Bool {
		return
			!(antigenTestProfile.firstName?.isEmpty ?? true) ||
			!(antigenTestProfile.lastName?.isEmpty ?? true) ||
			(antigenTestProfile.dateOfBirth != nil) ||
			!(antigenTestProfile.addressLine?.isEmpty ?? true) ||
			!(antigenTestProfile.zipCode?.isEmpty ?? true) ||
			!(antigenTestProfile.city?.isEmpty ?? true) ||
			!(antigenTestProfile.phoneNumber?.isEmpty ?? true) ||
			!(antigenTestProfile.email?.isEmpty ?? true)
	}

	func save() {
		store.antigenTestProfile = antigenTestProfile
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring

}
