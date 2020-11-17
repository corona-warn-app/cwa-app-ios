//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

struct DMSwitchCellViewModel {

	let labelText: String
	let isOn: () -> Bool
	let toggle: () -> Void

}

#endif
