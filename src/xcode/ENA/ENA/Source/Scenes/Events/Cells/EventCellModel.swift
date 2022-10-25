////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol EventCellModel {

	var isInactiveIconHiddenPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var isActiveContainerViewHiddenPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var isButtonHiddenPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var titleAccessibilityLabelPublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }
	var durationPublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }
	var durationAccessibilityPublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }
	var timePublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }
	var timeAccessibilityPublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }

	var isActiveIconHidden: Bool { get }
	var isDurationStackViewHidden: Bool { get }

	var title: NSAttributedString { get }
	var address: String { get }
	
	var buttonTitle: String { get }

}
