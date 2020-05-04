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

class FriendsInviteController: UIViewController {

    @IBAction func inviteAction(_ sender: UIButton) {

        //TODO insert correct app ID and link
        if let url = URL(string: "https://apps.apple.com/de/app/") {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.popoverPresentationController?.sourceView = self.view
            present(vc, animated: true)
        }
    }
}
