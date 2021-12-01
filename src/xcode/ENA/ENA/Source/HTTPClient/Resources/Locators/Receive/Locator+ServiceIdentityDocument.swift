//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {
	
	// send:	Empty
	// receive:	ServiceIdentityDocument
	// type:	dynamic pinning
	static func serviceIdentityDocument(
		endpointUrl: URL
	) -> Locator {
		Locator(
			endpoint: .dynamic(endpointUrl),
			paths: [String](),
			method: .get
		)
	}
	
}
