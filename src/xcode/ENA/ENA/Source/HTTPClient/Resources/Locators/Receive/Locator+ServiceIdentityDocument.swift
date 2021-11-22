//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {
	
	// send:	Empty
	// receive:	ServiceIdentityDocument
	// type:	dynamic pinning
	static func diagnosisKeys(
		urlString: StaticString
	) -> Locator {
		Locator(
			endpoint: .dynamic(URL(staticString: urlString)),
			paths: [String](),
			method: .get
		)
	}
	
}
