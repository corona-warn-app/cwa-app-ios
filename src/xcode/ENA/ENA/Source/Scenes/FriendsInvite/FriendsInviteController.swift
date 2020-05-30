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

import Foundation
import LinkPresentation
import UIKit

final class FriendsInviteController: UIViewController, UIActivityItemSource {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var inviteButton: ENAButton!

	let shareTitle = AppStrings.InviteFriends.shareTitle
	// swiftlint:disable:next force_unwrapping
	let shareUrl = URL(string: AppStrings.InviteFriends.shareUrl)!

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = AppStrings.InviteFriends.navigationBarTitle

		titleLabel.text = AppStrings.InviteFriends.title
		titleLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.boldSystemFont(ofSize: 22))
		titleLabel.adjustsFontForContentSizeCategory = true

		descriptionLabel.text = AppStrings.InviteFriends.description
		descriptionLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17))
		descriptionLabel.adjustsFontForContentSizeCategory = true

		inviteButton.setTitle(AppStrings.InviteFriends.submit, for: .normal)
		inviteButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

		guard let titleLabel = inviteButton.titleLabel else { return }
		titleLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
		titleLabel.adjustsFontForContentSizeCategory = true
		titleLabel.lineBreakMode = .byWordWrapping

		guard let inviteButton = inviteButton else { return }
		inviteButton.addConstraint(NSLayoutConstraint(item: inviteButton, attribute: .height, relatedBy: .equal, toItem: inviteButton.titleLabel, attribute: .height, multiplier: 1, constant: 0))
	}

	@IBAction func inviteAction(_: UIButton) {
		let inviteViewController = UIActivityViewController(activityItems: [self], applicationActivities: [])
		inviteViewController.popoverPresentationController?.sourceView = view
		present(inviteViewController, animated: true)
	}

	// MARK: UIActivityItemSource

	func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
		shareTitle
	}

	func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
		shareUrl
	}

	func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
		let metadata = LPLinkMetadata()

		metadata.title = shareTitle
		metadata.url = shareUrl
		metadata.originalURL = shareUrl

		if let appIcon = appIcon() {
			metadata.iconProvider = NSItemProvider(object: appIcon)
		}

		return metadata
	}

	func activityViewController(_: UIActivityViewController, subjectForActivityType _: UIActivity.ActivityType?) -> String {
		shareTitle
	}

	// MARK: Private functions

	private func appIcon() -> UIImage? {
		if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
			let icon = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let iconFiles = icon["CFBundleIconFiles"] as? [String],
			let lastIcon = iconFiles.last {
			return UIImage(named: lastIcon)
		}
		return nil
	}
}
