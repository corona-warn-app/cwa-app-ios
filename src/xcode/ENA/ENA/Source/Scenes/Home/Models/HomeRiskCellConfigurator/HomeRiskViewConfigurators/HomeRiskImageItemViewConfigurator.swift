//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeRiskImageItemViewConfigurator: HomeRiskViewConfigurator {
	var title: String
	var titleColor: UIColor
	var iconImageName: String
	var iconTintColor: UIColor
	var color: UIColor
	var separatorColor: UIColor

	var containerInsets: UIEdgeInsets?

	init(title: String, titleColor: UIColor, iconImageName: String, iconTintColor: UIColor, color: UIColor, separatorColor: UIColor) {
		self.title = title
		self.titleColor = titleColor
		self.iconImageName = iconImageName
		self.iconTintColor = iconTintColor
		self.color = color
		self.separatorColor = separatorColor
	}

	func configure(riskView: RiskImageItemView) {
		riskView.iconImageView?.image = UIImage(named: iconImageName)
		riskView.iconImageView.tintColor = iconTintColor
		riskView.textLabel?.text = title
		riskView.textLabel?.textColor = titleColor
		riskView.separatorView?.backgroundColor = separatorColor
		riskView.backgroundColor = color

		if let containerInsets = containerInsets {
			riskView.containerInsets = containerInsets
		}
	}
}
