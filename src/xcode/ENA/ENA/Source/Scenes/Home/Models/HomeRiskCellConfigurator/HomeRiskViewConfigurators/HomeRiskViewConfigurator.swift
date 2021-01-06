//
// 🦠 Corona-Warn-App
//

import UIKit

protocol HomeRiskViewConfiguratorAny {
	var viewAnyType: UIView.Type { get }

	func configureAny(riskView: UIView)
}

protocol HomeRiskViewConfigurator: HomeRiskViewConfiguratorAny {
	associatedtype ViewType: UIView
	func configure(riskView: ViewType)
}

extension HomeRiskViewConfigurator {
	var viewAnyType: UIView.Type {
		ViewType.self
	}

	func configureAny(riskView: UIView) {
		if let riskView = riskView as? ViewType {
			configure(riskView: riskView)
		} else {
			let error = "\(riskView) isn't conformed ViewType"
			Log.error(error, log: .ui)
			fatalError(error)
		}
	}
}
