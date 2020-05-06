//
//  DMDeveloperMenu.swift
//  ENA
//
//  Created by Kienle, Christian on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

/// The entry point of the developer menu infrastructure. This class can be considered a no op in `APP_STORE` builds.
///
/// If enabled, the developer can be revealed by tripple-tapping anywhere within the `presentingViewController`.
final class DMDeveloperMenu {
    // MARK: Creating a developer menu

    /// Parameters:
    /// - presentingViewController: The instance of `UIViewController` which should receive a developer menu.
    /// - client: The `Client` to use
    init(presentingViewController: UIViewController, client: Client) {
        self.client = client
        self.presentingViewController = presentingViewController
    }

    // MARK: Properties
    private let presentingViewController: UIViewController
    private let client: Client

    // MARK: Interacting with the developer menu

    /// Enables the developer menu if it is currently allowed to do so.
    ///
    /// Whether or not the developer menu is allowed is determined at build time by looking at the active build configuration. It is only allowed for `RELEASE` and `DEBUG` builds. Builds that target the app store (configuration `APP_STORE`) are built without support for a developer menu.
    func enableIfAllowed() {
        guard isAllowed() else {
            return
        }
        let showDeveloperMenuGesture = UITapGestureRecognizer(target: self, action: #selector(showDeveloperMenu(_:)))
        showDeveloperMenuGesture.numberOfTapsRequired = 3
        presentingViewController.view.addGestureRecognizer(showDeveloperMenuGesture)
    }

    @objc
    func showDeveloperMenu(_ sender: UITapGestureRecognizer) {
        let navigationController = UINavigationController(rootViewController: DMViewController(client: client))
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }

    private func isAllowed() -> Bool {
        #if RELEASE || DEBUG
            return true
        #else
            return false
        #endif
    }
}
