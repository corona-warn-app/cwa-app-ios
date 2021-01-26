//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum DynamicHeader {
	typealias HeaderConfigurator = (_ view: UIView, _ section: Int) -> Void

	case none
	case blank
	case space(height: CGFloat, color: UIColor? = nil)
	case text(_ text: String)
	case separator(color: UIColor, height: CGFloat = 1, insets: UIEdgeInsets = .zero)
	// swiftlint:disable:next enum_case_associated_values_count
	case image(_ image: UIImage?, accessibilityLabel: String? = nil, accessibilityIdentifier: String?, height: CGFloat? = nil, accessibilityTraits: UIAccessibilityTraits = .none)
	case view(_ view: UIView)
	case identifier(_ identifier: TableViewHeaderFooterReuseIdentifiers, action: DynamicAction = .none, configure: HeaderConfigurator? = nil)
	case cell(withIdentifier: TableViewCellReuseIdentifiers, configure: HeaderConfigurator? = nil)
	case custom(_ block: (DynamicTableViewController) -> UIView?)
}
