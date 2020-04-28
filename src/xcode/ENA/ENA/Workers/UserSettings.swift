//
//  UserSettings.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct UserSettings {
    @UserDefaultsStorage(key: "onboardingWasShown", defaultValue: false)
    static var onboardingWasShown: Bool
}
