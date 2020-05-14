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
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var inviteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = AppStrings.InviteFriends.navigationBarTitle

        titleLabel.text = AppStrings.InviteFriends.title
        descriptionTextView.text = AppStrings.InviteFriends.description
        inviteButton.setTitle(AppStrings.InviteFriends.submit, for: .normal)
    }

    @IBAction func inviteAction(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/de/app/") {
            let inviteViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
            inviteViewController.popoverPresentationController?.sourceView = view
            present(inviteViewController, animated: true)
        }
    }
}
