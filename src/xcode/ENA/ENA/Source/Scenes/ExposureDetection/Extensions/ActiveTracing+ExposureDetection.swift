//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit
import OpenCombine

extension ActiveTracing {

	var exposureDetectionActiveTracingSectionTextParagraph1: String {
		let format = NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph1", comment: "")
		return String(format: format, maximumNumberOfDays, inDays)
	}

	var exposureDetectionActiveTracingSectionTextParagraph0: String {
		return NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph0", comment: "")
	}

}
