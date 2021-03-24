////
// 🦠 Corona-Warn-App
//

enum TraceLocationTypeType {
	case permanent
	case temporary
	case unspecified
}

enum TraceLocationType: Int {

	case locationTypeUnspecified = 0
	case locationTypePermanentOther = 1
	case locationTypeTemporaryOther = 2
	case locationTypePermanentRetail = 3
	case locationTypePermanentFoodService = 4
	case locationTypePermanentCraft = 5
	case locationTypePermanentWorkplace = 6
	case locationTypePermanentEducationalInstitution = 7
	case locationTypePermanentPublicBuilding = 8
	case locationTypeTemporaryCulturalEvent = 9
	case locationTypeTemporaryClubActivity = 10
	case locationTypeTemporaryPrivateEvent = 11
	case locationTypeTemporaryWorshipService = 12

	var title: String {
		switch self {
		case .locationTypeUnspecified:
			return AppStrings.TraceLocations.unspecified.title
		case .locationTypePermanentOther:
			return AppStrings.TraceLocations.permanent.title.other
		case .locationTypeTemporaryOther:
			return AppStrings.TraceLocations.temporary.title.other
		case .locationTypePermanentRetail:
			return AppStrings.TraceLocations.permanent.title.retail
		case .locationTypePermanentFoodService:
			return AppStrings.TraceLocations.permanent.title.foodService
		case .locationTypePermanentCraft:
			return AppStrings.TraceLocations.permanent.title.craft
		case .locationTypePermanentWorkplace:
			return AppStrings.TraceLocations.permanent.title.workplace
		case .locationTypePermanentEducationalInstitution:
			return AppStrings.TraceLocations.permanent.title.educationalInstitution
		case .locationTypePermanentPublicBuilding:
			return AppStrings.TraceLocations.permanent.title.publicBuilding
		case .locationTypeTemporaryCulturalEvent:
			return AppStrings.TraceLocations.temporary.title.culturalEvent
		case .locationTypeTemporaryClubActivity:
			return AppStrings.TraceLocations.temporary.title.clubActivity
		case .locationTypeTemporaryPrivateEvent:
			return AppStrings.TraceLocations.temporary.title.privateEvent
		case .locationTypeTemporaryWorshipService:
			return AppStrings.TraceLocations.temporary.title.worshipService
		}
	}

	var subtitle: String? {
		switch self {
		case .locationTypeUnspecified:
			return nil
		case .locationTypePermanentOther:
			return nil
		case .locationTypeTemporaryOther:
			return nil
		case .locationTypePermanentRetail:
			return AppStrings.TraceLocations.permanent.subtitle.retail
		case .locationTypePermanentFoodService:
			return AppStrings.TraceLocations.permanent.subtitle.foodService
		case .locationTypePermanentCraft:
			return AppStrings.TraceLocations.permanent.subtitle.craft
		case .locationTypePermanentWorkplace:
			return AppStrings.TraceLocations.permanent.subtitle.workplace
		case .locationTypePermanentEducationalInstitution:
			return AppStrings.TraceLocations.permanent.subtitle.educationalInstitution
		case .locationTypePermanentPublicBuilding:
			return AppStrings.TraceLocations.permanent.subtitle.publicBuilding
		case .locationTypeTemporaryCulturalEvent:
			return AppStrings.TraceLocations.temporary.subtitle.culturalEvent
		case .locationTypeTemporaryClubActivity:
			return AppStrings.TraceLocations.temporary.subtitle.clubActivity
		case .locationTypeTemporaryPrivateEvent:
			return AppStrings.TraceLocations.temporary.subtitle.privateEvent
		case .locationTypeTemporaryWorshipService:
			return nil
		}
	}

	var type: TraceLocationTypeType {
		if Self.permanentTypes.contains(self) {
			return .permanent
		} else if Self.temporaryTypes.contains(self) {
			return .temporary
		} else {
			return .unspecified
		}
	}

	static let permanentTypes: [TraceLocationType] = [
		.locationTypePermanentRetail,
		.locationTypePermanentFoodService,
		.locationTypePermanentCraft,
		.locationTypePermanentWorkplace,
		.locationTypePermanentEducationalInstitution,
		.locationTypePermanentPublicBuilding,
		.locationTypePermanentOther
	]

	static let temporaryTypes: [TraceLocationType] = [
		.locationTypeTemporaryCulturalEvent,
		.locationTypeTemporaryClubActivity,
		.locationTypeTemporaryPrivateEvent,
		.locationTypeTemporaryWorshipService,
		.locationTypeTemporaryOther
	]

}
