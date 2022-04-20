////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class AntigenTestProfileInputViewModel {

	// MARK: - Init
	
	init(
		store: AntigenTestProfileStoring,
		antigenTestProfile: AntigenTestProfile
	) {
		self.store = store
		self.antigenTestProfile = antigenTestProfile
	}

	// MARK: - Internal
	
	@OpenCombine.Published var antigenTestProfile: AntigenTestProfile

	func save() {
		if let profileIndex = store.antigenTestProfiles.firstIndex(where: { $0.id == antigenTestProfile.id }) {
			store.antigenTestProfiles[profileIndex] = antigenTestProfile
		} else {
			store.antigenTestProfiles.append(antigenTestProfile)
		}
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
