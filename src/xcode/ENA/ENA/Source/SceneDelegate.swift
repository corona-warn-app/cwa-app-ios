//
//  SceneDelegate.swift
//  ENA
//
//  Created by Hu, Hao on 27.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: Properties
    var window: UIWindow?
    private let store = Store()
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

        let onboardingWasShown = store.isOnboarded
        //For a demo, we can set it to true.
        let instructor = LaunchInstructor.configure(onboardingWasShown: onboardingWasShown)
        let rootViewController: UIViewController
        switch instructor {
        case .home:
            let storyboard = AppStoryboard.home.instance
            // swiftlint:disable:next unowned_variable_capture
            let homeViewController = storyboard.instantiateInitialViewController { [unowned self] coder in
                HomeViewController(
                    coder: coder,
                    exposureManager: manager,
                    client: self.client,
                    store: self.store
                )
            }
            // swiftlint:disable:next force_unwrapping
            let navigationController = UINavigationController(rootViewController: homeViewController!)
            rootViewController = navigationController
			navigationController.navigationBar.prefersLargeTitles = true
			homeViewController?.navigationItem.largeTitleDisplayMode = .never
			
        case .onboarding:
            let storyboard = AppStoryboard.onboarding.instance
            let onboardingViewController = storyboard.instantiateInitialViewController { coder in
                OnboardingViewController(coder: coder, exposureManager: manager, store: self.store)
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
