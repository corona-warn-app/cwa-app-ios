//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeyModel: PaddingResource {
	let key: String
	let keyType: String
	// ToDo optional dob?
	var requestPadding: String = ""
}
