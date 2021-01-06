//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeRiskListItemViewConfigurator: HomeRiskViewConfigurator {
	var text: String
	var textColor: UIColor


	init(text: String, titleColor: UIColor) {
		self.text = text
		self.textColor = titleColor
	}

	func configure(riskView: RiskListItemView) {
		riskView.textLabel?.text = text
		riskView.textLabel?.textColor = textColor

		riskView.dotLabel?.text = "•"
		riskView.dotLabel?.textColor = textColor

	}
}
