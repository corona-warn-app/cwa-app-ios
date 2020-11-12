//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class TracingHistoryTableViewCell: UITableViewCell {
	@IBOutlet private var circleView: CircularProgressView!
	@IBOutlet private var historyLabel: UILabel!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var subtitleLabel: UILabel!

	func configure(
		progress: CGFloat,
		title: String,
		subtitle: String,
		text: String,
		colorConfigurationTuple: (UIColor, UIColor)
	) {
		titleLabel?.text = title
		subtitleLabel?.text = subtitle
		if circleView.progressBarColor != colorConfigurationTuple.0 {
			circleView.progressBarColor = colorConfigurationTuple.0
		}
		if circleView.circleColor != colorConfigurationTuple.1 {
			circleView.circleColor = colorConfigurationTuple.1
		}
		historyLabel.text = text
		circleView.progress = progress
	}
}
