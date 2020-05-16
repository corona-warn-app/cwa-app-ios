//
//  FriendsInviteController.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import LinkPresentation
import UIKit

final class FriendsInviteController: UIViewController, UIActivityItemSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inviteButton: ENAButton!

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

    @IBAction func inviteAction(_ sender: UIButton) {
        let inviteViewController = UIActivityViewController(activityItems: [self], applicationActivities: [])
        inviteViewController.popoverPresentationController?.sourceView = view
        present(inviteViewController, animated: true)
    }

    // MARK: UIActivityItemSource
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareTitle
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return shareUrl
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

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return shareTitle
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
