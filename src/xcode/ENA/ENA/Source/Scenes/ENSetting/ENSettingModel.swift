//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ENSettingModel {
	let content: [Content]
}

extension ENSettingModel {
	enum Content {
		case banner
		case actionCell
		case euTracingCell
		case tracingCell
		case actionDetailCell
		case descriptionCell
	}
}
