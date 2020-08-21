//
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
//

import Foundation
import UIKit

protocol HomeTestResultCollectionViewCellDelegate: class {
	func testResultCollectionViewCellPrimaryActionTriggered(_ collectionViewCell: HomeTestResultCollectionViewCell)
}

class HomeTestResultCollectionViewCell: HomeCardCollectionViewCell {
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var subtitleLabel: ENALabel!
	@IBOutlet var descriptionLabel: ENALabel!
	@IBOutlet var illustrationView: UIImageView!
	@IBOutlet var button: ENAButton!
	@IBOutlet var stackView: UIStackView!

	weak var delegate: HomeTestResultCollectionViewCellDelegate?

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	private func setup() {
		subtitleLabel.textColor = tintColor
		updateIllustration(for: traitCollection)

		setupAccessibility()
	}

	func configure(title: String, subtitle: String? = nil, description: String, button buttonTitle: String, image: UIImage?, tintColor: UIColor = .enaColor(for: .textPrimary1), accessibilityIdentifier: String?) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		descriptionLabel.text = description
		illustrationView?.image = image

		button.setTitle(buttonTitle, for: .normal)
		button.accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton

		subtitleLabel.isHidden = (nil == subtitle)
		button.accessibilityIdentifier = accessibilityIdentifier

		self.tintColor = tintColor
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		subtitleLabel.textColor = tintColor
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.superview?.isHidden = true
		} else {
			illustrationView.superview?.isHidden = false
		}
	}

	@IBAction func primaryActionTriggered() {
		delegate?.testResultCollectionViewCellPrimaryActionTriggered(self)
	}

	func setupAccessibility() {
		titleLabel.isAccessibilityElement = true
		subtitleLabel.isAccessibilityElement = true
		descriptionLabel.isAccessibilityElement = true
		isAccessibilityElement = false

		titleLabel.accessibilityTraits = [.header, .button]
	}
}
