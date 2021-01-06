//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeRiskTextItemViewConfigurator: HomeRiskViewConfigurator {
	var title: String
	var titleColor: UIColor
	var color: UIColor
	var separatorColor: UIColor

	init(title: String, titleColor: UIColor, color: UIColor, separatorColor: UIColor) {
		self.title = title
		self.titleColor = titleColor
		self.color = color
		self.separatorColor = separatorColor
	}

	func configure(riskView: RiskTextItemView) {
		riskView.titleLabel?.text = title
		riskView.titleLabel?.textColor = titleColor
		riskView.separatorView?.backgroundColor = separatorColor
		riskView.backgroundColor = color
	}
}
