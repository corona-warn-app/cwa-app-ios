//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	Protobuf SAP_Internal_Dgc_ValueSets
	// type:	caching
	// comment:
	static var vaccinationValueSets: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", Locale.current.languageCodeIfSupported ?? "en", "value-sets"],
			method: .get
		)
	}

}
