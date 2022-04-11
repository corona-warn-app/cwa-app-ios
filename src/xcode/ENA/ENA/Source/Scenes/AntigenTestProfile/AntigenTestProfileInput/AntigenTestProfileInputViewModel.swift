////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class AntigenTestProfileInputViewModel {

	// MARK: - Init
	
	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
		self.antigenTestProfile = store.antigenTestProfile ?? AntigenTestProfile()
	}

	// MARK: - Internal
	
	@OpenCombine.Published var antigenTestProfile: AntigenTestProfile

	func save() {
		store.antigenTestProfiles.append(antigenTestProfile)
	}
	
	func update(_ text: String?, keyPath: WritableKeyPath<AntigenTestProfile, String?>) {
		antigenTestProfile[keyPath: keyPath] = text
	}
	
	func update(_ date: Date?, keyPath: WritableKeyPath<AntigenTestProfile, Date?>) {
		antigenTestProfile[keyPath: keyPath] = date
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring

}

extension AntigenTestProfile {
	
	var isEligibleToSave: Bool {
		return !(firstName?.isEmpty ?? true) ||
			!(lastName?.isEmpty ?? true) ||
			(dateOfBirth != nil) ||
			!(addressLine?.isEmpty ?? true) ||
			!(zipCode?.isEmpty ?? true) ||
			!(city?.isEmpty ?? true) ||
			!(phoneNumber?.isEmpty ?? true) ||
			!(email?.isEmpty ?? true)
	}
}
