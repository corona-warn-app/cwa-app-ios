// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import UIKit

class PrivacyProtectionViewController: UIViewController {
	let gradient = CAGradientLayer()
	let blurEffectView = UIVisualEffectView()
	let label = UILabel()
	let logoImageView = UIImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		view.alpha = 0.0
		
		gradient.frame = self.view.bounds
		let appRedColor = UIColor(named: ColorStyle.brandRed.rawValue)?.withAlphaComponent(0.5).cgColor
		let appBlueColor = UIColor(named: ColorStyle.brandBlue.rawValue)?.withAlphaComponent(0.5).cgColor
		gradient.colors = [appRedColor ?? UIColor.clear.cgColor, appBlueColor ?? UIColor.clear.cgColor]
		view.layer.insertSublayer(gradient, at: 0)
		
		let blurEffect = UIBlurEffect(style: .systemMaterial)
		blurEffectView.effect = blurEffect
		blurEffectView.frame = self.view.bounds
		
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
		label.text = AppStrings.Common.privacyProtectionMessage
		let labelHeight = view.bounds.height * 0.66
		(label.frame, _) = blurEffectView.contentView.bounds.divided(atDistance: labelHeight, from: .minYEdge)
		
		let logo = UIImage(named: "cwa_logo.pdf")
		logoImageView.image = logo
		logoImageView.center = blurEffectView.center
		logoImageView.contentMode = .scaleAspectFit
		logoImageView.frame.size.width = 70
		logoImageView.frame.size.height = 70
		logoImageView.center = blurEffectView.center
		
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
		let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
		vibrancyView.translatesAutoresizingMaskIntoConstraints = false
		vibrancyView.frame = self.view.bounds
		vibrancyView.contentView.addSubview(label)
		vibrancyView.contentView.addSubview(logoImageView)
		blurEffectView.contentView.addSubview(vibrancyView)
		view.addSubview(blurEffectView)
	}
	
	func show() {
		UIView.animate(withDuration: 0.2, animations: {
			self.view.alpha = 1.0
		})
	}

	func hide(completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: 0.1, animations: {
			self.view.alpha = 0.0
		}, completion: { _ in
			completion?()
		})
	}
}
