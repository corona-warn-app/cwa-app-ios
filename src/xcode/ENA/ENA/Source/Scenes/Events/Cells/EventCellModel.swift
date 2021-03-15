////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol EventCellModel {

	var isInactiveIconHiddenPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var isActiveContainerViewHiddenPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var isButtonHiddenPublisher: OpenCombine.CurrentValueSubject<Bool, Never> { get }
	var durationPublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }
	var timePublisher: OpenCombine.CurrentValueSubject<String?, Never> { get }

	var isActiveIconHidden: Bool { get }
	var isDurationStackViewHidden: Bool { get }

	var date: String { get }

	var title: String { get }
	var address: String { get }

	var buttonTitle: String { get }

}
