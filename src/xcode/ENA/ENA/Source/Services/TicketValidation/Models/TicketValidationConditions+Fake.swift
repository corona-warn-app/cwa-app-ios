//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

extension TicketValidationConditions {

	static func fake(
		hash: String? = nil,
		lang: String? = nil,
		fnt: String? = nil,
		gnt: String? = nil,
		dob: String? = nil,
		type: [String]? = nil,
		coa: String? = nil,
		roa: String? = nil,
		cod: String? = nil,
		rod: String? = nil,
		category: [String]? = nil,
		validationClock: String? = nil,
		validFrom: String? = nil,
		validTo: String? = nil
	) -> TicketValidationConditions {
		TicketValidationConditions(
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
