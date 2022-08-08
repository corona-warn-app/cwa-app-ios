////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol AddButtonAsTableViewCelling {

	var text: String { get }
	var accessibilityIdentifier: String? { get }

	var iconImagePublisher: OpenCombine.CurrentValueSubject<UIImage?, Never> { get }
	var textColorPublisher: OpenCombine.CurrentValueSubject<UIColor, Never> { get }
	var accessibilityTraitsPublisher: OpenCombine.CurrentValueSubject<UIAccessibilityTraits, Never> { get }
	var isCustomAccessoryViewHiddenPublisher: CurrentValueSubject<Bool, Never> { get }

}
