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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        setupRootViewController()
        window.makeKeyAndVisible()

        NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
    }

    private func setupRootViewController() {
        let manager = ExposureManager()

        let onboardingWasShown = PersistenceManager.shared.isOnboarded
        //For a demo, we can set it to true.
        let instructor = LaunchInstructor.configure(onboardingWasShown: onboardingWasShown)
        let rootViewController: UIViewController
        switch instructor {
        case .home:
            let storyboard = AppStoryboard.home.instance
            let homeViewController = storyboard.instantiateInitialViewController { coder -> HomeViewController? in
                HomeViewController(coder: coder, exposureManager: manager)
            }
            rootViewController = homeViewController!
        case .onboarding:
            let storyboard = AppStoryboard.onboarding.instance
            let onboardingViewController = storyboard.instantiateInitialViewController { coder -> OnboardingViewController? in
                OnboardingViewController(coder: coder, exposureManager: manager)
            }
            rootViewController = onboardingViewController!
        }

        window?.rootViewController = rootViewController
    }

    @objc
	func isOnboardedDidChange(_ notification: NSNotification) {
        setupRootViewController()
    }
}
