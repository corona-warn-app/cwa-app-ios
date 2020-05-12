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
    @IBAction func inviteAction(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/de/app/") {
            let inviteViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
            inviteViewController.popoverPresentationController?.sourceView = view
            present(inviteViewController, animated: true)
        }
    }
}
