//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

struct DMSwitchCellViewModel {

	let labelText: String
	let isEnabled: () -> Bool
	let toggle: () -> Void

}

#endif
