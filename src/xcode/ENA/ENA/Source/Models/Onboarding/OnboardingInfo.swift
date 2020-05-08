//
//  OnboardingInfo.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct OnboardingInfo {
    var title: String
    var imageName: String
    var text: String
}

extension OnboardingInfo {
    static func testData() -> [Self] {
        // swiftlint:disable line_length
        let info1 = OnboardingInfo(title: "Small title", imageName: "onboarding_1", text: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
        // swiftlint:disable line_length
        let info2 = OnboardingInfo(title: "Everything new in iOS 13.5 beta 3 - Face ID changes, and Exposure Notification", imageName: "onboarding_2", text: "On Face ID-enabled iPhones, it is slightly more difficult to unlock your phone while wearing a face mask. With this update, Face ID will recognize the mask and automatically prompt you to enter your passcode, rather than waiting for Face ID to time out.")
        // swiftlint:disable line_length
        let info3 = OnboardingInfo(title: "Apple's latest iOS 13.5 beta adds new features and settings all designed to aid in the fight against COVID-19. AppleInsider digs into the latest update to see what is coming as the update approaches release.", imageName: "onboarding_3", text: "The new beta of iOS 13.5 is actually the third beta of iOS 13.4.5 that Apple had to relabel due to the inclusion of its COVID-19 tracking SDK. This new SDK and API will allow certain developers to create apps that are able to aid in contact tracing those who are diagnosed with COVID-19. Aside from this SDK being included, Apple also included a toggle within settings to disable COVID-19 exposure notifications. Currently, in the beta, it is opt-out rather than opt-in. Right now, though, it still needs the user to download an official app that doesn't exist yet to utilize the feature.")
        return [info1, info2, info3]
    }
}
