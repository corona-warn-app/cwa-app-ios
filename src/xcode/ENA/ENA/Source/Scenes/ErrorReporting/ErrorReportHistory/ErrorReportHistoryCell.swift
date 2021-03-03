//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ErrorReportHistoryCell: UITableViewCell {
		
	@IBOutlet weak var dateTimeLabel: ENALabel!
	@IBOutlet weak var idLabel: ENALabel!
	
	// MARK: - Internal

	func configure(
		dateTimeLabel: NSMutableAttributedString,
		idLabel: NSMutableAttributedString
		
	) {
		self.dateTimeLabel.attributedText = dateTimeLabel
		self.idLabel.attributedText = idLabel
	}
}
