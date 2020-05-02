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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onboardingFlagDidChange(_:)), name: .onboardingFlagDidChange, object: nil)
    }
    
    private func setupRootViewController() {
        
        
        let onboardingWasShown = PersistenceManager.shared.isOnboarded
        //For a demo, we can set it to true.
        let instructor = LaunchInstructor.configure(onboardingWasShown: onboardingWasShown)
        let rootViewController: UIViewController
        switch instructor {
        case .main:
            rootViewController = HomeScreenViewController.initiate(for: .main)
        case .onboarding:
            rootViewController = OnboardingViewController.initiate(for: .onboarding)
        }
        
        window?.rootViewController = rootViewController
    }
    
    @objc func onboardingFlagDidChange(_ notification: NSNotification) {
        setupRootViewController()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

