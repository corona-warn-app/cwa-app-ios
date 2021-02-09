//
// 🦠 Corona-Warn-App
//

import Foundation

enum AgeGroup: Int, CaseIterable, Codable {

	case ageBelow29 = 1
	case ageBetween30And59 = 2
	case age60OrAbove = 3

	// MARK: - Init

	init(from ageGroup: AgeGroup) {
		switch ageGroup {
		case .ageBelow29:
			self = .ageBelow29
		case .ageBetween30And59:
			self = .ageBetween30And59
		case .age60OrAbove:
			self = .age60OrAbove
		}
	}

	// MARK: - Internal

	// MARK: - Private

	var text: String {
		switch self {
		case .ageBelow29:
			return AppStrings.DataDonation.ValueSelection.Ages.Below29
		case .ageBetween30And59:
			return AppStrings.DataDonation.ValueSelection.Ages.Between30And59
		case .age60OrAbove:
			return AppStrings.DataDonation.ValueSelection.Ages.Min60OrAbove
		}
	}

}
