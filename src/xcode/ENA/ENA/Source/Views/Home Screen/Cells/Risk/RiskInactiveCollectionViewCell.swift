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

protocol RiskInactiveCollectionViewCellDelegate: AnyObject {
	func activeButtonTapped(cell: RiskInactiveCollectionViewCell)
}

final class RiskInactiveCollectionViewCell: HomeCardCollectionViewCell {

	weak var delegate: RiskInactiveCollectionViewCellDelegate?

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var chevronImageView: UIImageView!
	@IBOutlet var bodyLabel: UILabel!
	@IBOutlet var activeButton: UIButton!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var topContainer: UIView!
	@IBOutlet var stackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		constructStackView()
		constructActiveButton()
		topContainer.layoutMargins = .zero
	}

	private func constructStackView() {
		let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
		stackView.layoutMargins = containerInsets
		stackView.isLayoutMarginsRelativeArrangement = true
	}

	private func constructActiveButton() {
		activeButton.titleLabel?.adjustsFontForContentSizeCategory = true
		activeButton.titleLabel?.lineBreakMode = .byWordWrapping
		activeButton.layer.cornerRadius = 10.0
		activeButton.layer.masksToBounds = true
		activeButton.contentEdgeInsets = .init(top: 14.0, left: 8.0, bottom: 14.0, right: 8.0)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		activeButton.titleLabel?.lineBreakMode = traitCollection.preferredContentSizeCategory >= .accessibilityMedium ? .byTruncatingMiddle : .byWordWrapping
	}

	@IBAction func activeButtonTapped(_: UIButton) {
		delegate?.activeButtonTapped(cell: self)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		removeAllArrangedSubviews()
	}
	
	func removeAllArrangedSubviews() {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
		stackView.addArrangedSubview(topContainer)
	}

	func configureBody(text: String, bodyColor: UIColor) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
		stackView.addArrangedSubview(bodyLabel)
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureChevron(image: UIImage?, tintColor: UIColor) {
		chevronImageView.image = image
		chevronImageView.tintColor = tintColor
	}

	func configureActiveButton(title: String, color: UIColor, backgroundColor: UIColor) {
		UIView.performWithoutAnimation {
			activeButton.setTitle(title, for: .normal)
			activeButton.layoutIfNeeded()
		}
		activeButton.setTitleColor(color, for: .normal)
		activeButton.setTitleColor(color.withAlphaComponent(0.3), for: .disabled)
		activeButton.backgroundColor = backgroundColor
		stackView.addArrangedSubview(activeButton)
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
		if let riskItemView = stackView.arrangedSubviews.last as? RiskItemViewSeparatorable {
			riskItemView.hideSeparator()
		}
	}
}
