//
// 🦠 Corona-Warn-App
//

import Foundation

enum VaccinationProductType {
	case biontech
	case moderna
	case astraZeneca
	case other

	// MARK: - Init

	init(value: String) {
		switch value.uppercased() {
		case "EU/1/20/1528":
			self = .biontech
		case "EU/1/20/1507":
			self = .moderna
		case "EU/1/21/1529":
			self = .astraZeneca
		default:
			self = .other
		}
	}
}
