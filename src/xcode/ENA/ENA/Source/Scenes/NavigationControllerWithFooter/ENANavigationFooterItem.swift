//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ENANavigationFooterItem: UINavigationItem {
	@IBInspectable dynamic var isPrimaryButtonHidden: Bool = false
	@IBInspectable dynamic var isPrimaryButtonEnabled: Bool = true
	@IBInspectable dynamic var isPrimaryButtonLoading: Bool = false
	@IBInspectable dynamic var primaryButtonTitle: String = ""

	@IBInspectable dynamic var isSecondaryButtonHidden: Bool = true
	@IBInspectable dynamic var isSecondaryButtonEnabled: Bool = true
	@IBInspectable dynamic var isSecondaryButtonLoading: Bool = false
	@IBInspectable dynamic var secondaryButtonTitle: String = ""
	@IBInspectable dynamic var secondaryButtonHasBorder: Bool = false
	@IBInspectable dynamic var secondaryButtonHasBackground: Bool = false
}
