//
//  OnboardingPermission.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct OnboardingPermissions {
    var title: String
    var imageName: String
    
    var bluetoothTitle: String
    var notificationsTitle: String
}

extension OnboardingPermissions {
    static func testData() -> Self {
        let onboardingPermissions = OnboardingPermissions(title: "Permissions", imageName: "onboarding_note", bluetoothTitle: "Bluetooth", notificationsTitle: "Notifications")
        return onboardingPermissions
    }
}
