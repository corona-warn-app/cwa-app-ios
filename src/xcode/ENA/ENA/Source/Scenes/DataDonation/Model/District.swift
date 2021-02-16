//
// 🦠 Corona-Warn-App
//

import Foundation

struct DistrictElement: Codable {

	let districtName: String
	let districtShortName: String
	let districtID: Int
	let federalStateName: FederalStateName
	let federalStateShortName: FederalStateShortName
	let federalStateID: Int

	enum CodingKeys: String, CodingKey {
		case districtName
		case districtShortName
		case districtID = "districtId"
		case federalStateName, federalStateShortName
		case federalStateID = "federalStateId"
	}
}

enum FederalStateName: String, CaseIterable, Codable {
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

	var protobuf: SAP_Internal_Ppdd_PPAFederalState {
		switch self {
		case .badenWürttemberg:
			return .federalStateBw
		case .bayern:
			return .federalStateBy
		case .berlin:
			return .federalStateBe
		case .brandenburg:
			return .federalStateBb
		case .bremen:
			return .federalStateHb
		case .hamburg:
			return .federalStateHh
		case .hessen:
			return .federalStateHe
		case .mecklenburgVorpommern:
			return .federalStateMv
		case .niedersachsen:
			return .federalStateNi
		case .nordrheinWestfalen:
			return .federalStateNrw
		case .rheinlandPfalz:
			return .federalStateRp
		case .saarland:
			return .federalStateSl
		case .sachsen:
			return .federalStateSn
		case .sachsenAnhalt:
			return .federalStateSt
		case .schleswigHolstein:
			return .federalStateSh
		case .thüringen:
			return .federalStateTh
		}
	}
}

enum FederalStateShortName: String, CaseIterable, Codable {
	case bb = "BB"
	case be = "BE"
	case bw = "BW"
	case by = "BY"
	case hb = "HB"
	case he = "HE"
	case hh = "HH"
	case mv = "MV"
	case ni = "NI"
	case nw = "NW"
	case rp = "RP"
	case sh = "SH"
	case sl = "SL"
	case sn = "SN"
	case st = "ST"
	case th = "TH"
}
