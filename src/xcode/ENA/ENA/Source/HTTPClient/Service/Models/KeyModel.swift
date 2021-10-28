//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeyModel: PaddingResource {
	let key: String
	let keyType: String
	// we might need dob later here
	var requestPadding: String = ""
}
