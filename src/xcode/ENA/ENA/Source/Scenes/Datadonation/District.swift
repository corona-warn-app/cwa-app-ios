////
// 🦠 Corona-Warn-App
//

import Foundation

struct DistrictElement: Codable {

	let districtName, districtShortName: String
	let districtID: Int
	let federalStateName: FederalStateName
	let federalStateShortName: FederalStateShortName
	let federalStateID: Int

	enum CodingKeys: String, CodingKey {
		case districtName, districtShortName
		case districtID = "districtId"
		case federalStateName, federalStateShortName
		case federalStateID = "federalStateId"
	}
}

enum FederalStateName: String, Codable {
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
}

enum FederalStateShortName: String, Codable {
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
