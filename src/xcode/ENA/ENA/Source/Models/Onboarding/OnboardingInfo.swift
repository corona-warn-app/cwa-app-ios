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
			 title:
			 AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title,
			 imageName: "onboarding_1",
			 boldText: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_boldText,
			 text: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_normalText
		 )
		 
		 let info2 = OnboardingInfo(
			 title: AppStrings.Onboarding.onboardingInfo_privacyPage_title,
			 imageName: "onboarding_2",
			 boldText: AppStrings.Onboarding.onboardingInfo_privacyPage_boldText,
			 text: AppStrings.Onboarding.onboardingInfo_privacyPage_normalText
		 )
		 
		 let info3 = OnboardingInfo(
			 title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_title,
			 imageName: "onboarding_3",
			 boldText: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_boldText,
			 text: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_normalText
		 )
		 
		 let info4 = OnboardingInfo(
			 title: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title,
			 imageName: "onboarding_1",
			 boldText: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_boldText,
			 text: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_normalText
		 )
		
		 let info5 = OnboardingInfo(
			 title: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_title,
			 imageName: "onboarding_2",
			 boldText: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_boldText,
			 text: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_normalText
		 )

        return [info1, info2, info3, info4, info5]
    }
}
