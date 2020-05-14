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
    var boldText: String
    var text: String
}

extension OnboardingInfo {
    static func testData() -> [Self] {
        
        let info1 = OnboardingInfo(
            title: NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_title", comment: ""),
            imageName: "onboarding_1",
            boldText: NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_boldText", comment: ""),
            text: NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_normalText", comment: "")
		)
        
        let info2 = OnboardingInfo(
            title: NSLocalizedString("OnboardingInfo_privacyPage_title", comment: ""),
            imageName: "onboarding_2",
            boldText: NSLocalizedString("OnboardingInfo_privacyPage_boldText", comment: ""),
            text: NSLocalizedString("OnboardingInfo_privacyPage_normalText", comment: "")
		)
        
        let info3 = OnboardingInfo(
            title: NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_title", comment: ""),
            imageName: "onboarding_3",
            boldText: NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_boldText", comment: ""),
            text: NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_normalText", comment: "")
		)
        
        let info4 = OnboardingInfo(
            title: NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_title", comment: ""),
            imageName: "onboarding_1",
            boldText: NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_boldText", comment: ""),
            text: NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_normalText", comment: "")
		)
       
        let info5 = OnboardingInfo(
            title: NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_title", comment: ""),
            imageName: "onboarding_2",
            boldText: NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_boldText", comment: ""),
            text: NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_normalText", comment: "")
		)

        return [info1, info2, info3, info4, info5]
    }
}
