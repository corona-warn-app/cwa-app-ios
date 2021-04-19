//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIView {

	var asPDF: NSData {
		let pageDimensions = bounds
		let outputData = NSMutableData()

		UIGraphicsBeginPDFContextToData(outputData, pageDimensions, nil)
		if let context = UIGraphicsGetCurrentContext() {
			UIGraphicsBeginPDFPage()
			layer.render(in: context)
		}
		UIGraphicsEndPDFContext()

		return outputData
	}

}
