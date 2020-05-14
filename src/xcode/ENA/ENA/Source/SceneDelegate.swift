//
//  SceneDelegate.swift
//  ENA
//
//  Created by Hu, Hao on 27.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private(set) var client: Client = {
        let mode = Mode.from()

        switch mode {
        case .development:
            return HTTPClient(configuration: .development)
        case .production:
            return HTTPClient(configuration: .production)
        case .mock:
            return MockClient()
        }
       }()

    // MARK: UISceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        setupRootViewController()
        window.makeKeyAndVisible()

        NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
    }

    // MARK: Helper
    private func setupRootViewController() {
        let manager = ENAExposureManager()

        let onboardingWasShown = true// PersistenceManager.shared.isOnboarded
        //For a demo, we can set it to true.
        let instructor = LaunchInstructor.configure(onboardingWasShown: onboardingWasShown)
        let rootViewController: UIViewController
        switch instructor {
        case .home:
            let storyboard = AppStoryboard.home.instance
            let homeViewController = storyboard.instantiateInitialViewController { coder in
                HomeViewController(coder: coder, exposureManager: manager, client: self.client)
            }
            // swiftlint:disable:next force_unwrapping
            rootViewController = homeViewController!
        case .onboarding:
            let storyboard = AppStoryboard.onboarding.instance
            let onboardingViewController = storyboard.instantiateInitialViewController { coder in
                OnboardingViewController(coder: coder, exposureManager: manager)
            }
            // swiftlint:disable:next force_unwrapping
            rootViewController = onboardingViewController!
        }

        window?.rootViewController = rootViewController
    }

    @objc
	func isOnboardedDidChange(_ notification: NSNotification) {
        setupRootViewController()
    }
}
