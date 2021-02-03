//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

public struct DMSwitchCellViewModel {

	let labelText: String
	let isOn: () -> Bool
	let toggle: () -> Void

}

#endif
