//
// 🦠 Corona-Warn-App
//

import Foundation
import LinkPresentation
import UIKit

final class InviteFriendsViewController: UIViewController, UIActivityItemSource {

	// MARK: - Init

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		navigationItem.title = AppStrings.InviteFriends.navigationBarTitle

		if #available(iOS 13, *) {
			subtitleLabelTopConstraint.constant = 0
		} else {
			subtitleLabelTopConstraint.constant = 10
		}

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

	// MARK: - Protocol UIActivityItemSource

	func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
		return shareTitle
	}

	func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		if activityType == .mail {
			return ""
		}

		return shareTitle
	}

	@available(iOS 13.0, *)
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

	// MARK: - Private

	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var descriptionLabel: UILabel!
	@IBOutlet private weak var inviteButton: ENAButton!
	@IBOutlet private weak var subtitleLabel: UILabel!
	@IBOutlet private weak var subtitleLabelTopConstraint: NSLayoutConstraint!
	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var footerView: UIView!
	@IBOutlet private weak var imageView: UIImageView!

	private let shareTitle = AppStrings.InviteFriends.shareTitle
	// swiftlint:disable:next force_unwrapping
	private let shareUrl = URL(string: AppStrings.InviteFriends.shareUrl)!

	@IBAction private func inviteAction(_: UIButton) {
		let inviteViewController = UIActivityViewController(activityItems: [self, shareUrl], applicationActivities: [])
		inviteViewController.popoverPresentationController?.sourceView = view

		present(inviteViewController, animated: true)
	}

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
