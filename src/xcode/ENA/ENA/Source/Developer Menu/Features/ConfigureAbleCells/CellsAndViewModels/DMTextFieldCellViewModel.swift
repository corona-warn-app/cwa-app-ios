////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

struct DMTextFieldCellViewModel {

	// MARK: - Internal

	let labelText: String
	let textFieldDidChange: (String) -> Void
}

#endif
