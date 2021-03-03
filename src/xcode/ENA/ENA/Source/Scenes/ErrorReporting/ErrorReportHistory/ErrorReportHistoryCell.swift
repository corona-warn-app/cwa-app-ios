//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ErrorReportHistoryCell: UITableViewCell {
		
	@IBOutlet private var dateTimeLabel: ENALabel!
	@IBOutlet private var idLabel: ENALabel!
	
	func configure(
		dateTimeLabel: NSMutableAttributedString,
		idLabel: NSMutableAttributedString
		
	) {
		self.dateTimeLabel.attributedText = dateTimeLabel
		self.idLabel.attributedText = idLabel
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}
}
