//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

public struct DMSwitchCellViewModel {

	// MARK: - Internal

	let labelText: String
	let isOn: () -> Bool
	let toggle: () -> Void

}

#endif
