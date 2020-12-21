//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeRiskLoadingItemViewConfigurator: HomeRiskViewConfigurator {

	var title: String
	var titleColor: UIColor
	var isActivityIndicatorOn: Bool
	var color: UIColor
	var separatorColor: UIColor

	init(title: String, titleColor: UIColor, isActivityIndicatorOn: Bool, color: UIColor, separatorColor: UIColor) {
		self.title = title
		self.titleColor = titleColor
		self.isActivityIndicatorOn = isActivityIndicatorOn
		self.color = color
		self.separatorColor = separatorColor
	}

	func configure(riskView: RiskLoadingItemView) {
		let iconTintColor = titleColor
		riskView.activityIndicatorView.color = iconTintColor
		riskView.textLabel?.text = title
		riskView.textLabel?.textColor = titleColor
		riskView.separatorView?.backgroundColor = separatorColor
		if isActivityIndicatorOn {
			riskView.activityIndicatorView.startAnimating()
		} else {
			riskView.activityIndicatorView.stopAnimating()
		}
		riskView.backgroundColor = color
	}
}
