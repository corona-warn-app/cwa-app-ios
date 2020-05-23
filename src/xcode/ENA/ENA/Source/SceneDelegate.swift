//
//  SceneDelegate.swift
//  ENA
//
//  Created by Hu, Hao on 27.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: Properties
    var window: UIWindow?
    private let store = Store()
    private let diagnosisKeysStore = SignedPayloadStore()
    private let exposureManager = ENAExposureManager()
    private let navigationController: UINavigationController = .withLargeTitle()

    private(set) lazy var client: Client = {
        #if APP_STORE
        return HTTPClient(configuration: .production)
        #endif

        if ClientMode.default == .mock {
            fatalError("Please implement")
        }
        
        let store = self.store
        guard
            let distributionURLString = store.developerDistributionBaseURLOverride,
            let submissionURLString = store.developerSubmissionBaseURLOverride,
            let distributionURL = URL(string: distributionURLString),
            let submissionURL = URL(string: submissionURLString) else {
                return HTTPClient(configuration: .production)
        }

        let config = HTTPClient.Configuration(
            apiVersion: "v1",
            country: "DE",
            endpoints: HTTPClient.Configuration.Endpoints(
                distribution: .init(baseURL: distributionURL, requiresTrailingSlash: false),
                submission: .init(baseURL: submissionURL, requiresTrailingSlash: true)
            )
        )
        return HTTPClient(configuration: config)
    }()

    // MARK: UISceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        exposureManager.resume(observer: self)
        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
    }

    // MARK: Helper
    private func setupUI() {
        store.isOnboarded ? showHome() : showOnboarding()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    private func showHome(animated: Bool = false) {
        navigationController.setViewControllers(
            [
                AppStoryboard.home.initiateInitial { [unowned self] coder in
                    HomeViewController(
                        coder: coder,
                        exposureManager: self.exposureManager,
                        client: self.client,
                        store: self.store,
                        signedPayloadStore: self.diagnosisKeysStore
                    )
                }
            ],
            animated: true
        )
    }

    private func showOnboarding() {
        navigationController.setViewControllers(
            [
                AppStoryboard.onboarding.initiateInitial { [unowned self] coder in
                    OnboardingInfoViewController(
                        coder: coder,
                        pageType: .togetherAgainstCoronaPage,
                        exposureManager: self.exposureManager,
                        store: self.store
                    )
                }
            ],
            animated: false)
    }

    @objc
    func isOnboardedDidChange(_ notification: NSNotification) {
        showHome(animated: true)
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

extension SceneDelegate: ENAExposureManagerObserver {
    func exposureManager(
        _ manager: ENAExposureManager,
        didChangeState newState: ExposureManagerState
    ) {
        let message = """
        New status of EN framework:
        Authorized: \(newState.authorized)
        enabled: \(newState.enabled)
        active: \(newState.active)
        """
        log(message: message)
        
        if newState.isGood {
            log(message: "Enabled")
        }
    }
}

private extension UINavigationController {
    class func withLargeTitle() -> UINavigationController {
        let result = UINavigationController()
        result.navigationBar.prefersLargeTitles = true
        return result
    }
}

private extension Array where Element == URLQueryItem {
    func valueFor(queryItem named: String) -> String? {
        first(where: { $0.name == named })?.value
    }
}
