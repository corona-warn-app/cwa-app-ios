//
// 🦠 Corona-Warn-App
//

import class CertLogic.Rule

extension Rule {

	func localizedDescription(locale: Locale = Locale.current) -> String {
		let localizedDescription = description.first(where: { $0.lang.lowercased() == locale.languageCode?.lowercased() })?.desc
		let englishDescription = description.first(where: { $0.lang.lowercased() == "en" })?.desc
		let firstDescription = description.first?.desc

		return localizedDescription ?? englishDescription ?? firstDescription ?? identifier
	}

}
