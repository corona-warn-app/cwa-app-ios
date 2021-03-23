////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol AddEventCellModel {

	var text: String { get }

	var iconImagePublisher: OpenCombine.CurrentValueSubject<UIImage?, Never> { get }
	var textColorPublisher: OpenCombine.CurrentValueSubject<UIColor, Never> { get }
	var accessibilityTraitsPublisher: OpenCombine.CurrentValueSubject<UIAccessibilityTraits, Never> { get }

}
