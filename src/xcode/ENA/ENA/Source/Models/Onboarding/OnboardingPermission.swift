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
    var permissions: [OnboardingPermission]
}

enum OnboardingPermission: CaseIterable {
    
    case bluetooth
    case notifications
    
    var title: String {
        switch self {
        case .bluetooth:
            return "Bluetooth"
        case .notifications:
            return "Notifications"
        }
    }
}

extension OnboardingPermissions {
    static func testData() -> Self {
        let permissions = OnboardingPermission.allCases
        let onboardingPermissions = OnboardingPermissions(title: "Permissions", imageName: "onboarding_note", permissions: permissions)
        return onboardingPermissions
    }
}
