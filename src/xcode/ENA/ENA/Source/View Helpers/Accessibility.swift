// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import UIKit

/**

 The string values can be simple & generic (eg, in the case of "next"), or highly specific (eg, "Home_Activate_Title", from the Localizble.strings file)

 */

enum Accessibility {
	enum Alert {
		static let exposureNotifications = "Enable COVID-19 Exposure Notifications From “Corona-Warn”?"
		static let localNotifications = "“Corona-Warn” Would Like to Send You Notifications"
		static let dontAllowButton = "Don’t Allow"
		static let cancelButton = "Cancel"
		static let allowButton = "Allow"
		static let okButton = "Ok"
	}

	enum StaticText {
		static let onboardingTitle = "OnboardingInfo_togetherAgainstCoronaPage_title"
		static let homeActivateTitle = "Home_Activate_Title"
	}

	enum Button {
		static let next = "next"
		static let ignore = "ignore"
		static let finish = "finish"
	}

	enum Cell {
		static let infoCardShareTitle = "infoCardShareTitle"
		static let infoCardAboutTitle = "infoCardAboutTitle"
		static let appInformationCardTitle = "appInformationCardTitle"
		static let settingsCardTitle = "settingsCardTitle"
	}

}
