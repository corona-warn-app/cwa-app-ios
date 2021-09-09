//
// 🦠 Corona-Warn-App
//

import class CertLogic.Rule

extension Rule {

	var localizedDescription: String {
		let localizedDescription = description.first(where: { $0.lang.lowercased() == Locale.current.languageCode?.lowercased() })?.desc
		let englishDescription = description.first(where: { $0.lang.lowercased() == "en" })?.desc
		let firstDescription = description.first?.desc

		return localizedDescription ?? englishDescription ?? firstDescription ?? identifier
	}

}
