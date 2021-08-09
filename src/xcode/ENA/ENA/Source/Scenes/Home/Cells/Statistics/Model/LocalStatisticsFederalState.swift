//
// 🦠 Corona-Warn-App
//

import Foundation


/// Federal states for usage in (local) statistics
///
/// we have to create another enum to avoid confusion also because the enum order for the 16 states federalStateId in PPA is different that LocalStatistics protobufs
enum LocalStatisticsFederalState: String, CaseIterable, Codable {
	case badenWürttemberg = "Baden-Württemberg"
	case bayern = "Bayern"
	case berlin = "Berlin"
	case brandenburg = "Brandenburg"
	case bremen = "Bremen"
	case hamburg = "Hamburg"
	case hessen = "Hessen"
	case mecklenburgVorpommern = "Mecklenburg-Vorpommern"
	case niedersachsen = "Niedersachsen"
	case nordrheinWestfalen = "Nordrhein-Westfalen"
	case rheinlandPfalz = "Rheinland-Pfalz"
	case saarland = "Saarland"
	case sachsen = "Sachsen"
	case sachsenAnhalt = "Sachsen-Anhalt"
	case schleswigHolstein = "Schleswig-Holstein"
	case thüringen = "Thüringen"

	/// mapping to localized names for federal states
	var localizedName: String {
		switch self {
		case .badenWürttemberg:
			return AppStrings.FederalStateName.badenWuerttemberg
		case .bayern:
			return AppStrings.FederalStateName.bayen
		case .berlin:
			return AppStrings.FederalStateName.berlin
		case .brandenburg:
			return AppStrings.FederalStateName.brandenburg
		case .bremen:
			return AppStrings.FederalStateName.bremen
		case .hamburg:
			return AppStrings.FederalStateName.hamburg
		case .hessen:
			return AppStrings.FederalStateName.hessen
		case .mecklenburgVorpommern:
			return AppStrings.FederalStateName.mecklenburgVorpommern
		case .niedersachsen:
			return AppStrings.FederalStateName.niedersachsen
		case .nordrheinWestfalen:
			return AppStrings.FederalStateName.nordrheinWestfalen
		case .rheinlandPfalz:
			return AppStrings.FederalStateName.rheinlandPfalz
		case .saarland:
			return AppStrings.FederalStateName.saarland
		case .sachsen:
			return AppStrings.FederalStateName.sachsen
		case .sachsenAnhalt:
			return AppStrings.FederalStateName.sachsenAnhalt
		case .schleswigHolstein:
			return AppStrings.FederalStateName.schleswigHolstein
		case .thüringen:
			return AppStrings.FederalStateName.thueringen
		}
	}

	/// A group of 1..n federal states
	var groupID: Int {
		switch self {
		case .badenWürttemberg:
			return 1
		case .bayern:
			return 2
		case .berlin, .brandenburg, .mecklenburgVorpommern:
			return 3
		case .bremen, .hamburg, .niedersachsen, .schleswigHolstein:
			return 4
		case .nordrheinWestfalen:
			return 5
		case .sachsen, .sachsenAnhalt, .thüringen:
			return 6
		case .hessen, .rheinlandPfalz, .saarland:
			return 7
		}
	}

	/// Mapping to int values
	var federalStateId: Int {
		switch self {
		case .schleswigHolstein:
			return 1
		case .hamburg:
			return 2
		case .niedersachsen:
			return 3
		case .bremen:
			return 4
		case .nordrheinWestfalen:
			return 5
		case .hessen:
			return 6
		case .rheinlandPfalz:
			return 7
		case .badenWürttemberg:
			return 8
		case .bayern:
			return 9
		case .saarland:
			return 10
		case .berlin:
			return 11
		case .brandenburg:
			return 12
		case .mecklenburgVorpommern:
			return 13
		case .sachsen:
			return 14
		case .sachsenAnhalt:
			return 15
		case .thüringen:
			return 16
		}
	}
	
	// the FederalStates inside the returned in local_statistics.pb start from zero so this is to make the correct mapping
	var federalStateProtobufId: Int {
		return self.federalStateId - 1
	}
}
