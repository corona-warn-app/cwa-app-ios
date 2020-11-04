import Foundation
import LinkPresentation
import UIKit

final class FriendsInviteController: UIViewController {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var inviteButton: ENAButton!
	@IBOutlet var subtitleLabel: UILabel!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var footerView: UIView!
	@IBOutlet weak var imageView: UIImageView!

	private let shareTitle = AppStrings.InviteFriends.shareTitle
	// swiftlint:disable:next force_unwrapping
	private let shareUrl = URL(string: AppStrings.InviteFriends.shareUrl)!

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = AppStrings.InviteFriends.navigationBarTitle

		subtitleLabel.text = AppStrings.InviteFriends.subtitle
		titleLabel.text = AppStrings.InviteFriends.title
		descriptionLabel.text = AppStrings.InviteFriends.description
		imageView.isAccessibilityElement = true
		imageView.accessibilityLabel = AppStrings.InviteFriends.imageAccessLabel
		imageView.accessibilityIdentifier = AccessibilityIdentifiers.InviteFriends.imageAccessLabel

		inviteButton.setTitle(AppStrings.InviteFriends.submit, for: .normal)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		scrollView.contentInset.bottom = footerView.frame.height
	}

	@IBAction func inviteAction(_: UIButton) {
		let inviteViewController = UIActivityViewController(activityItems: [self, shareUrl], applicationActivities: [])
		inviteViewController.popoverPresentationController?.sourceView = view
		present(inviteViewController, animated: true)
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

extension FriendsInviteController: UIActivityItemSource {
	func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
		return shareTitle
	}

	func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		if activityType == .mail {
			return ""
		}

		return shareTitle
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
		return shareTitle
	}
}
