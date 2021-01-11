//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

enum DatePickerDay: Equatable {
	case moreThan21DaysAgo(Date)
	case upTo21DaysAgo(Date)
	case today(Date)
	case future(Date)
}
