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

final class FriendsInviteController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inviteButton: ENAButton!

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
        inviteButton.titleLabel?.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
        inviteButton.titleLabel?.adjustsFontForContentSizeCategory = true
        inviteButton.titleLabel?.lineBreakMode = .byTruncatingHead
    }

    @IBAction func inviteAction(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/de/app/") {
            let inviteViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
            inviteViewController.popoverPresentationController?.sourceView = view
            present(inviteViewController, animated: true)
        }
    }
}
