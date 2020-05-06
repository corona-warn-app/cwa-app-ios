//
//  AppStoryboard.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

enum AppStoryboard: String {
    case home = "Home"
    case onboarding = "Onboarding"
    case exposureNotificationSetting = "ExposureNotificationSetting"
    case exposureSubmission = "ExposureSubmission"
    case settings = "Settings"
    case developerMenu = "DeveloperMenu"
    case inviteFriends = "InviteFriends"
    case appInformation = "AppInfo"
    case exposureDetection = "ExposureDetection"
    case selfExposureTanEntry = "selfExposureTanEntry"
    case selfExposureConfirmation = "selfExposureConfirmation"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }

    func initiate<T: UIViewController>(viewControllerType: T.Type) -> T {
        let storyboard = UIStoryboard(name: rawValue, bundle: nil)
        let viewControllerIdentifier = viewControllerType.stringName()
        guard let vc = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? T else { fatalError("Can't initiate \(viewControllerIdentifier) for \(rawValue) storyboard") }
        return vc
    }
    
    func initiateInitial() -> UIViewController {
        let storyboard = UIStoryboard(name: rawValue, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { fatalError("Can't initiate start UIViewController for \(rawValue) storyboard") }
        return vc
    }
    
}
