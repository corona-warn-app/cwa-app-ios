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

protocol RiskLevelCollectionViewCellDelegate: AnyObject {
	func updateButtonTapped(cell: RiskLevelCollectionViewCell)
}

/// A cell that visualizes the current risk and allows the user to calculate he/his current risk.
final class RiskLevelCollectionViewCell: HomeCardCollectionViewCell {
	// MARK: Properties

	weak var delegate: RiskLevelCollectionViewCellDelegate?

	// MARK: Outlets

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var chevronImageView: UIImageView!
	@IBOutlet var bodyLabel: ENALabel!
	@IBOutlet var updateButton: ENACloneButton!
	@IBOutlet var detectionIntervalLabel: ENALabel!
	@IBOutlet var detectionIntervalLabelContainer: UIView!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var topContainer: UIView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var riskViewStackView: UIStackView!

	// MARK: Nib Loading

	override func awakeFromNib() {
		super.awakeFromNib()
		constructStackView()
		constructCounterLabelContainer()
		topContainer.layoutMargins = .zero
	}

	private func constructStackView() {
		let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
		stackView.layoutMargins = containerInsets
		stackView.isLayoutMarginsRelativeArrangement = true
	}

	private func constructCounterLabelContainer() {
		detectionIntervalLabelContainer.layer.cornerRadius = 18.0
		detectionIntervalLabelContainer.layer.masksToBounds = true
		detectionIntervalLabelContainer.layoutMargins = .init(top: 9.0, left: 16.0, bottom: 9.0, right: 16.0)
		detectionIntervalLabelContainer.backgroundColor = UIColor.black.withAlphaComponent(0.12)
		detectionIntervalLabel.textColor = .systemGray6
	}

	// Ignore touches on the button when it's disabled
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let buttonPoint = convert(point, to: updateButton)
		let containsPoint = updateButton.bounds.contains(buttonPoint)
		if containsPoint, !updateButton.isEnabled {
			return nil
		}
		return super.hitTest(point, with: event)
	}

	// MARK: Actions

	@IBAction func updateButtonTapped(_: UIButton) {
		delegate?.updateButtonTapped(cell: self)
	}

	// MARK: Configuring the UI

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
	}

	func configureBody(text: String, bodyColor: UIColor, isHidden: Bool) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
		bodyLabel.isHidden = isHidden
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureUpdateButton(title: String, isEnabled: Bool, isHidden: Bool) {
		updateButton.setTitle(title, for: .normal)
		updateButton.isEnabled = isEnabled
		updateButton.isHidden = isHidden
	}

	func configureDetectionIntervalLabel(text: String, isHidden: Bool) {
		detectionIntervalLabel.text = text
		detectionIntervalLabel.isHidden = isHidden
		detectionIntervalLabelContainer.isHidden = isHidden
	}

	func configureRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {

		riskViewStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for itemConfigurator in cellConfigurators {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
				riskViewStackView.addArrangedSubview(riskView)
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
	
		if let riskItemView = stackView.arrangedSubviews.last as? RiskItemViewSeparatorable {
			riskItemView.hideSeparator()
		}

		riskViewStackView.isHidden = cellConfigurators.isEmpty
	}
}
