//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ErrorReportHistoryCell: UITableViewCell {
		
	@IBOutlet private var dateTimeLabel: ENALabel!
	@IBOutlet private var idLabel: ENALabel!
	
	// MARK: - Internal

	func configure(
		dateTimeLabel: NSMutableAttributedString,
		idLabel: NSMutableAttributedString
		
	) {
		self.dateTimeLabel.attributedText = dateTimeLabel
		self.idLabel.attributedText = idLabel
	}
}
