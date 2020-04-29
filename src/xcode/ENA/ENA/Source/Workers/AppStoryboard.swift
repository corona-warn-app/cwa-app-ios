//
//  AppStoryboard.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

enum AppStoryboard: String {
    case main = "Main"
    case tabbar = "Tabbar"
    case onboarding = "Onboarding"

    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }

    func initiate<T: UIViewController>(viewControllerType: T.Type) -> T {
        let storyboard = UIStoryboard(name: rawValue, bundle: nil)
        let viewControllerIdentifier = viewControllerType.stringName()
        guard let vc = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? T else { fatalError("Can't initiate \(viewControllerIdentifier) for \(rawValue) storyboard") }
        return vc
    }
}
