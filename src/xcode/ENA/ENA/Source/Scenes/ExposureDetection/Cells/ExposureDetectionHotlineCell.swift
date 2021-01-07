//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureDetectionHotlineCell: UITableViewCell {
	@IBOutlet var hotlineContentView: ExposureDetectionHotlineCellContentView!

	override func prepareForReuse() {
		super.prepareForReuse()
		hotlineContentView.primaryAction = nil
	}
}

@IBDesignable
class ExposureDetectionHotlineCellContentView: UIView {
	var primaryAction: (() -> Void)?

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		awakeFromNib()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		layer.cornerRadius = 16
		layer.shadowRadius = 36
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.15
		layer.shadowOffset = CGSize(width: 0, height: 10)
	}

	@IBAction func triggerPrimaryAction() {
		primaryAction?()
	}
}
