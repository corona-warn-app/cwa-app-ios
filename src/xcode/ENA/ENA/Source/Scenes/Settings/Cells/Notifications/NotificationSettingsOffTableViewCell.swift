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

class NotificationSettingsOffTableViewCell: UITableViewCell {
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var descriptionLabel: DynamicTypeLabel!

	@IBOutlet var descriptionLabelTrailingConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabelLeadingConstraint: NSLayoutConstraint!
	@IBOutlet var imageViewCenterYConstraint: NSLayoutConstraint!
	@IBOutlet var imageViewFirstBaselineConstraint: NSLayoutConstraint!

	let labelPadding: CGFloat = 10

	private var regularConstraints: [NSLayoutConstraint] = []
	private var largeTextConstraints: [NSLayoutConstraint] = []

	override func awakeFromNib() {
		super.awakeFromNib()

		setLayoutConstraints()
	}

	func configure(viewModel: NotificationSettingsViewModel.SettingsOffItem) {
		iconImageView.image = UIImage(named: viewModel.icon)

		updateDescriptionLabel(viewModel.description)
		updateLayoutConstraints()
	}

	private func setLayoutConstraints() {
		regularConstraints = [descriptionLabelTrailingConstraint, imageViewCenterYConstraint]

		let labelHalfCapHeight = descriptionLabel.font.capHeight / 2
		imageViewFirstBaselineConstraint.constant = labelHalfCapHeight

		largeTextConstraints = [descriptionLabelLeadingConstraint, imageViewFirstBaselineConstraint]
	}

	private func updateLayoutConstraints() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			NSLayoutConstraint.deactivate(regularConstraints)
			NSLayoutConstraint.activate(largeTextConstraints)
		} else {
			NSLayoutConstraint.deactivate(largeTextConstraints)
			NSLayoutConstraint.activate(regularConstraints)
		}
	}

	private func updateDescriptionLabel(_ value: String) {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.setParagraphStyle(NSParagraphStyle.default)

		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			paragraphStyle.firstLineHeadIndent = iconImageView.frame.size.width + labelPadding
		}

		let attributedString = NSAttributedString(
			string: value,
			attributes: [
				NSAttributedString.Key.paragraphStyle: paragraphStyle,
				NSAttributedString.Key.font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
			]
		)
		descriptionLabel.attributedText = attributedString
	}
}
