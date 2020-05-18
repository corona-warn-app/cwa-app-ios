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
    private let diagnosisKeysStore = SignedPayloadStore()

    private(set) lazy var client: Client = {
        #if APP_STORE
            return HTTPClient(configuration: .production)
        #endif

        if Mode.from() == .mock {
            return MockClient()
        }
        
        let store = self.store
        guard
            let distributionURLString = store.developerDistributionBaseURLOverride,
            let submissionURLString = store.developerSubmissionBaseURLOverride,
            let distributionURL = URL(string: distributionURLString),
            let submissionURL = URL(string: submissionURLString) else {
                return HTTPClient(configuration: .production)
        }


        let config = BackendConfiguration(
            endpoints: .init(
                distribution: distributionURL,
                submission: submissionURL
            )
        )
        return HTTPClient(configuration: config)
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
            // swiftlint:disable:next unowned_variable_capture
            let homeViewController = AppStoryboard.home.initiateInitial { [unowned self] coder in
                HomeViewController(
                    coder: coder,
                    exposureManager: manager,
                    client: self.client,
                    store: self.store,
                    signedPayloadStore: self.diagnosisKeysStore
                )
            }
            // swiftlint:disable:next force_unwrapping
            let navigationController = UINavigationController(rootViewController: homeViewController!)
            rootViewController = navigationController
			navigationController.navigationBar.prefersLargeTitles = true
			homeViewController?.navigationItem.largeTitleDisplayMode = .never
			
        case .onboarding:
            let storyboard = AppStoryboard.onboarding.instance
			// swiftlint:disable:next unowned_variable_capture
            let onboardingViewController = storyboard.instantiateInitialViewController { [unowned self] coder in
				OnboardingInfoViewController(
					coder: coder,
					pageType: .togetherAgainstCoronaPage,
					exposureManager: manager,
					store: self.store
				)
			}
            // swiftlint:disable:next force_unwrapping
            let navigationController = UINavigationController(rootViewController: onboardingViewController!)
            rootViewController = navigationController
		}

        window?.rootViewController = rootViewController
    }

    @objc
	func isOnboardedDidChange(_ notification: NSNotification) {
        setupRootViewController()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        #if APP_STORE
        return
        #endif

        guard let url = URLContexts.first?.url else {
            return
        }

        guard let components = NSURLComponents(
            url: url,
            resolvingAgainstBaseURL: true
            ),
            let query = components.queryItems else {
                return
        }

        if let submissionBaseURL = query.valueFor(queryItem: "submissionBaseURL") {
            store.developerSubmissionBaseURLOverride = submissionBaseURL
        }
        if let distributionBaseURL = query.valueFor(queryItem: "distributionBaseURL") {
            store.developerDistributionBaseURLOverride = distributionBaseURL
        }

        UserDefaults.standard.synchronize()
    }
}

private extension Array where Element == URLQueryItem {
    func valueFor(queryItem named: String) -> String? {
        first(where: { $0.name == named })?.value
    }
}
