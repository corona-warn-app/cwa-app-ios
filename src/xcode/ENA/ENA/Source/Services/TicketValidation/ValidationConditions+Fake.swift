//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

extension ValidationConditions {

	static func fake(
		hash: String? = nil,
		lang: String? = nil,
		fnt: String? = "Naveed",
		gnt: String? = "Khalid",
		dob: String? = "26-06-1991",
		type: [String]? = ["v", "r", "t"],
		coa: String? = nil,
		roa: String? = nil,
		cod: String? = nil,
		rod: String? = nil,
		category: [String]? = nil,
		validationClock: Date? = nil,
		validFrom: Date? = nil,
		validTo: Date? = nil
	) -> ValidationConditions {
		ValidationConditions(
			hash: hash,
			lang: lang,
			fnt: fnt,
			gnt: gnt,
			dob: dob,
			type: type,
			coa: coa,
			roa: roa,
			cod: cod,
			rod: rod,
			category: category,
			validationClock: validationClock,
			validFrom: validFrom,
			validTo: validTo
		)
	}

}

#endif
