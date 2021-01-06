//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum DynamicAction {
	case none
	case call(number: String)
	case open(url: URL?)
	case execute(block: (_ viewController: UIViewController, _ cell: UITableViewCell?) -> Void)
}
