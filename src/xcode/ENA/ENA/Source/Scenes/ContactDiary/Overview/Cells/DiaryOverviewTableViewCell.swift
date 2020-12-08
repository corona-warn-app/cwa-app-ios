////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	// MARK: - Internal

	func configure(day: DiaryDay) {
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEEddMMyy")

		dateLabel.text = dateFormatter.string(from: day.date)
	}

	// MARK: - Private

	@IBOutlet private weak var dateLabel: UILabel!
    
}
