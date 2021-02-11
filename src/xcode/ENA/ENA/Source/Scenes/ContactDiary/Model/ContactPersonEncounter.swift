////
// 🦠 Corona-Warn-App
//

import Foundation

struct ContactPersonEncounter: Equatable {

	// MARK: - Init

	enum Duration: Int {
		case none
		case lessThan15Minutes
		case moreThan15Minutes
	}

	enum MaskSituation: Int {
		case none
		case withMask
		case withoutMask
	}

	enum LocationType: Int {
		case none
		case outside
		case inside
	}

	init(
		id: Int,
		date: String,
		contactPersonId: Int,
		duration: Duration = .none,
		maskSituation: MaskSituation = .none,
		locationType: LocationType = .none,
		circumstances: String = ""
	) {
		self.id = id
		self.date = date
		self.contactPersonId = contactPersonId
		self.duration = duration
		self.maskSituation = maskSituation
		self.locationType = locationType
		self.circumstances = circumstances
	}


	// MARK: - Internal

	let id: Int
	let date: String
	let contactPersonId: Int

	let duration: Duration
	let maskSituation: MaskSituation
	let locationType: LocationType

	let circumstances: String
	
}
