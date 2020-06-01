//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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
//

import UIKit

final class RiskThankYouCollectionViewCell: HomeCardCollectionViewCell {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var bodyLabel: UILabel!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var stackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		constructStackView()
	}

	private func constructStackView() {
		let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
		stackView.layoutMargins = containerInsets
		stackView.isLayoutMarginsRelativeArrangement = true
	}

	func removeAllArrangedSubviews() {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
		stackView.addArrangedSubview(stackView)
	}

	func configureBody(text: String, bodyColor: UIColor) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
		stackView.addArrangedSubview(bodyLabel)
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		for itemConfigurator in cellConfigurators {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
				stackView.addArrangedSubview(riskView)
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		if let riskItemView = stackView.arrangedSubviews.last as? RiskItemView {
			riskItemView.hideSeparator()
		}
	}
}
