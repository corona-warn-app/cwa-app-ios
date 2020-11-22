//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol DynamicTableViewTextCell: UITableViewCell {
	func configureDynamicType(size: CGFloat, weight: UIFont.Weight, style: UIFont.TextStyle)
	func configure(text: String, color: UIColor?)
	func configureAccessibility(label: String?, identifier: String?, traits: UIAccessibilityTraits)
}
