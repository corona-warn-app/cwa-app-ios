////
// 🦠 Corona-Warn-App
//

import Foundation

struct ContactPersonEncounter: Equatable {

	// MARK: - Init

	enum Duration: Int {
		case lessThan15Minutes, moreThan15Minutes
	}

	enum MaskSituation: Int {
		case withMask, withoutMask
	}

	enum LocationType: Int {
		case outside, inside
	}

	init(
		id: Int,
		date: String,
		contactPersonId: Int,
		duration: Duration? = nil,
		maskSituation: MaskSituation? = nil,
		locationType: LocationType? = nil,
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

	let duration: Duration?
	let maskSituation: MaskSituation?
	let locationType: LocationType?

	let circumstances: String
	
}
