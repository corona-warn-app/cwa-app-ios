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

final class RiskLoadingItemView: UIView, RiskItemView {
	@IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet var titleTextView: UITextView!
	@IBOutlet var separatorView: UIView!
	@IBOutlet var separatorHeightConstraint: NSLayoutConstraint!

	@IBOutlet var topActivityIndicatorTopTextViewConstraint: NSLayoutConstraint!
	@IBOutlet var centerYActivityIndicatorCenterYTextViewConstraint: NSLayoutConstraint!

	@IBOutlet var leadingTextViewLeadingMarginConstraint: NSLayoutConstraint!
	@IBOutlet var leadingTextViewTrailingActivityIndicatorViewConstraint: NSLayoutConstraint!

	private let titleTopPadding: CGFloat = 8.0

	override func awakeFromNib() {
		super.awakeFromNib()
		separatorHeightConstraint.constant = 1
		titleTextView.textContainerInset = .zero
		titleTextView.textContainer.lineFragmentPadding = 0
		titleTextView.textContainerInset = .init(top: titleTopPadding, left: 0.0, bottom: titleTopPadding, right: 0.0)
		titleTextView.isUserInteractionEnabled = false
		activityIndicatorView.startAnimating()
		configureTextViewLayout()
		configureActivityIndicatorView()
		wrapActivityIndicator()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		wrapActivityIndicator()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureTextViewLayout()
		configureActivityIndicatorView()
	}

	private func configureTextViewLayout() {
		let greaterThanAccessibilityMedium = traitCollection.preferredContentSizeCategory >= .accessibilityMedium
		if greaterThanAccessibilityMedium {
			leadingTextViewLeadingMarginConstraint.isActive = true
			leadingTextViewTrailingActivityIndicatorViewConstraint.isActive = false
		} else {
			leadingTextViewLeadingMarginConstraint.isActive = false
			leadingTextViewTrailingActivityIndicatorViewConstraint.isActive = true
		}
	}

	private func configureActivityIndicatorView() {
		let greaterThanAccessibilityMedium = traitCollection.preferredContentSizeCategory >= .accessibilityMedium
		activityIndicatorView.style = greaterThanAccessibilityMedium ? .large : .medium
	}

	private func wrapActivityIndicator() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
			centerYActivityIndicatorCenterYTextViewConstraint.isActive = false
			topActivityIndicatorTopTextViewConstraint.isActive = true
			guard let lineHeight = titleTextView.font?.lineHeight else { return }

			var indicatorFrame = convert(activityIndicatorView.frame, to: titleTextView)
			let offset: CGFloat = (lineHeight - indicatorFrame.height) / 2.0
			topActivityIndicatorTopTextViewConstraint.constant = max(offset.rounded(), 0) + titleTopPadding
			let iconTitleDistance = leadingTextViewTrailingActivityIndicatorViewConstraint.constant
			indicatorFrame.size = CGSize(width: indicatorFrame.width + iconTitleDistance, height: indicatorFrame.height)
			let bezierPath = UIBezierPath(rect: indicatorFrame)
			titleTextView.textContainer.exclusionPaths = [bezierPath]
		} else {
			centerYActivityIndicatorCenterYTextViewConstraint.isActive = true
			topActivityIndicatorTopTextViewConstraint.isActive = false
			titleTextView.textContainer.exclusionPaths.removeAll()
		}
	}

	func hideSeparator() {
		separatorView.isHidden = true
	}
}
