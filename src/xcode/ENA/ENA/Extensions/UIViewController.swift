//
//  UIViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Returns the instance of Self created from specified storyboard.
    /// ViewController should have Storyboard ID in the storyboard.
    ///
    /// Usage: ViewController.initiate(for: .main)
    ///
    /// - Parameter storyboard: The name of the storyboard.
    /// - Returns: The instance of Self.
    static func initiate(for storyboard: AppStoryboard) -> Self {
        storyboard.initiate(viewControllerType: self)
    }
}
