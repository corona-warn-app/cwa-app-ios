//
//  AccessibilityIdentifiers.swift
//  ENA
//
//  Created by Dunne, Liam on 14/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

/**

The string values can be simple & generic (eg, in the case of "next"), or highly specific (eg, "Home_Activate_Title", from the Localizble.strings file)

*/

enum Accessibility {
	enum StaticText {
		static let onboardingTitle = "OnboardingInfo_togetherAgainstCoronaPage_title"
		static let homeActivateTitle = "Home_Activate_Title"
	}
	enum Button {
		static let next = "next"
		static let ignore = "ignore"
		static let finish = "finish"
	}
	enum Alert {
		
	}
}
