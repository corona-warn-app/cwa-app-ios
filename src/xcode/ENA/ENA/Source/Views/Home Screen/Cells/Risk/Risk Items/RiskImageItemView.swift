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

final class RiskImageItemView: UIView, RiskItemView {
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var titleTextView: UITextView!
	@IBOutlet var separatorView: UIView!
	@IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
	@IBOutlet var topImageTopTextViewConstraint: NSLayoutConstraint!
	
	@IBOutlet var leadingTextViewLeadingMarginConstraint: NSLayoutConstraint!
	@IBOutlet var leadingTextViewTrailingImageViewConstraint: NSLayoutConstraint!
	
	private let titleTopPadding: CGFloat = 8.0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		separatorHeightConstraint.constant = 1
		titleTextView.textContainerInset = .zero
		titleTextView.textContainer.lineFragmentPadding = 0
		titleTextView.textContainerInset = .init(top: titleTopPadding, left: 0.0, bottom: titleTopPadding, right: 0.0)
		titleTextView.isUserInteractionEnabled = false
		configureTextViewLayout()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		wrapImage()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureTextViewLayout()
	}
	
	private func configureTextViewLayout() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
			leadingTextViewLeadingMarginConstraint.isActive = true
			leadingTextViewTrailingImageViewConstraint.isActive = false
		} else {
			leadingTextViewLeadingMarginConstraint.isActive = false
			leadingTextViewTrailingImageViewConstraint.isActive = true
		}
	}
	
	private func wrapImage() {
		guard let lineHeight = titleTextView.font?.lineHeight else { return }
		
		var iconImageFrame = convert(iconImageView.frame, to: titleTextView)
		let offset: CGFloat = (lineHeight - iconImageFrame.height) / 2.0
		
		topImageTopTextViewConstraint.constant = max(offset.rounded(), 0) + titleTopPadding
		let iconTitleDistance = leadingTextViewTrailingImageViewConstraint.constant
		iconImageFrame.size = CGSize(width: iconImageFrame.width + iconTitleDistance, height: iconImageFrame.height)
		let bezierPath = UIBezierPath(rect: iconImageFrame)
		titleTextView.textContainer.exclusionPaths = [bezierPath]
	}
	
	func hideSeparator() {
		separatorView.isHidden = true
	}
}
