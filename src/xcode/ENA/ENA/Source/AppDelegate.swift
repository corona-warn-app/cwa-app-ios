//
//  AppDelegate.swift
//  ENA
//
//  Created by Hu, Hao on 27.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import CoreData
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
    static let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"

    func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		registerBackgroundTask()
		scheduleBackgroundTaskIfNeeded()
		return true
	}
	
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
 
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

extension AppDelegate {
	func scheduleBackgroundTaskIfNeeded() {
		guard
			ENAExposureManager().preconditions().contains(.authorized),
			ENAExposureManager().preconditions().contains(.enabled),
			ENAExposureManager().preconditions().contains(.active)
		else {
			return
		}
		
		let taskRequest = BGProcessingTaskRequest(identifier: AppDelegate.backgroundTaskIdentifier)
		taskRequest.requiresNetworkConnectivity = true
		do {
			try BGTaskScheduler.shared.submit(taskRequest)
		} catch {
			print("Unable to schedule background task: \(error)")
		}
	}

	func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppDelegate.backgroundTaskIdentifier, using: .main) { task in
            
            // #TODO: Perform the exposure detection
//			let progress = ENAExposureManager().detectExposures(
//				configuration: config <#T##ENExposureConfiguration#>,
//				diagnosisKeyURLs: <#T##[URL]#>
//				) { success in
//				task.setTaskCompleted(success: success)
//			}

//            // #TODO: Handle running out of time
//            task.expirationHandler = {
//				progress.cancel()
//				logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
//            }
            
            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()
        }
	}
	
}
