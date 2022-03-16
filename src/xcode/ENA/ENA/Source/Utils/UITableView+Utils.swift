//
// 🦠 Corona-Warn-App
//

import UIKit

extension UITableView {
	
	func updateHeights() {
		// From the docs (https://developer.apple.com/documentation/uikit/uitableview/1614908-beginupdates)
		// "You can also use this method followed by the endUpdates() method to animate the change in the row heights without reloading the cell."
		beginUpdates()
		endUpdates()
	}
	
}
