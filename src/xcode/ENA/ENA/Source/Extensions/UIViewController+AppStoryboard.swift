//
//  UIViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

extension UIViewController {
    static func initiate(for storyboard: AppStoryboard) -> Self {
        storyboard.initiate(viewControllerType: self)
    }
}
