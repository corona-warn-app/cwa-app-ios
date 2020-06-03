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

protocol RiskFindingPositiveCollectionViewCellDelegate: AnyObject {
	func nextButtonTapped(cell: RiskFindingPositiveCollectionViewCell)
}

final class RiskFindingPositiveCollectionViewCell: HomeCardCollectionViewCell {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var chevronImageView: UIImageView!

	@IBOutlet var statusTitleLabel: UILabel!
	@IBOutlet var statusSubtitleLabel: UILabel!
	@IBOutlet var statusImageView: UIImageView!
	@IBOutlet var statusLineView: UIView!

	@IBOutlet var noteLabel: UILabel!
	@IBOutlet var nextButton: UIButton!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var topContainer: UIView!
	@IBOutlet var statusContainer: UIView!
	@IBOutlet var stackView: UIStackView!

	weak var delegate: RiskFindingPositiveCollectionViewCellDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()
		constructStackView()
		constructNextButton()
		topContainer.layoutMargins = .zero
		statusContainer.layoutMargins = .init(top: 0, left: 12.0, bottom: 0.0, right: 12.0)
		statusLineView.layer.cornerRadius = 2.0
		statusLineView.layer.masksToBounds = true
	}

	@IBAction func nextButtonTapped(_: UIButton) {
		delegate?.nextButtonTapped(cell: self)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		nextButton.titleLabel?.lineBreakMode = traitCollection.preferredContentSizeCategory >= .accessibilityMedium ? .byTruncatingMiddle : .byWordWrapping
		configureStackView()
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			statusImageView.isHidden = true
		} else {
			statusImageView.isHidden = false
		}
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
		stackView.addArrangedSubview(topContainer)
		stackView.setCustomSpacing(32.0, after: topContainer)
	}

	func configureChevron(image: UIImage?, tintColor: UIColor) {
		chevronImageView.image = image
		chevronImageView.tintColor = tintColor
	}

	func configureStatus(title: String, subtitle: String, titleColor: UIColor, lineColor: UIColor, imageName: String) {

		statusTitleLabel.text = title
		statusSubtitleLabel.text = subtitle

		statusTitleLabel.textColor = titleColor
		statusSubtitleLabel.textColor = titleColor

		statusLineView.backgroundColor = lineColor

		let image = UIImage(named: imageName)
		statusImageView.image = image
		stackView.addArrangedSubview(statusContainer)
		stackView.setCustomSpacing(32.0, after: statusContainer)
	}

	func configureNoteLabel(title: String) {
		noteLabel.text = title
		stackView.addArrangedSubview(noteLabel)
		stackView.setCustomSpacing(8.0, after: noteLabel)
	}

	private func constructNextButton() {
		nextButton.titleLabel?.adjustsFontForContentSizeCategory = true
		nextButton.titleLabel?.lineBreakMode = .byWordWrapping
		nextButton.layer.cornerRadius = 10.0
		nextButton.layer.masksToBounds = true
		nextButton.contentEdgeInsets = .init(top: 14.0, left: 8.0, bottom: 14.0, right: 8.0)
	}

	func configureNextButton(title: String, color: UIColor, backgroundColor: UIColor) {
		UIView.performWithoutAnimation {
			nextButton.setTitle(title, for: .normal)
			nextButton.layoutIfNeeded()
		}
		nextButton.setTitleColor(color, for: .normal)
		nextButton.setTitleColor(color.withAlphaComponent(0.3), for: .disabled)
		nextButton.backgroundColor = backgroundColor
		stackView.addArrangedSubview(nextButton)
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureNoteRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		guard let noteIndex = stackView.arrangedSubviews.firstIndex(of: noteLabel) else { return }
		var lastView: UIView?
		for itemConfigurator in cellConfigurators.reversed() {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? RiskItemView {
				stackView.insertArrangedSubview(riskView, at: noteIndex + 1)
				if lastView != nil {
					stackView.setCustomSpacing(0.0, after: riskView)
				} else {
					lastView = riskView
				}
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		if let last = lastView {
			stackView.setCustomSpacing(22.0, after: last)
		}
	}

}
