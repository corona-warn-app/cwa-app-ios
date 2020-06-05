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

enum AppStoryboard: String {
	case home = "Home"
	case onboarding = "Onboarding"
	case exposureNotificationSetting = "ExposureNotificationSetting"
	case exposureSubmission = "ExposureSubmission"
	case settings = "Settings"
	case developerMenu = "DeveloperMenu"
	case inviteFriends = "InviteFriends"
	case exposureDetection = "ExposureDetection"
	case riskLegend = "RiskLegend"

	var instance: UIStoryboard {
		UIStoryboard(name: rawValue, bundle: nil)
	}

	func initiate<T: UIViewController>(viewControllerType: T.Type, creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
		let storyboard = UIStoryboard(name: rawValue, bundle: nil)
		let viewControllerIdentifier = viewControllerType.stringName()
		guard let vc = storyboard.instantiateViewController(identifier: viewControllerIdentifier, creator: creator) as? T else {
			let error = "Can't initiate \(viewControllerIdentifier) for \(rawValue) storyboard"
			logError(message: error)
			fatalError(error)
		}
		return vc
	}

	func initiateInitial<T: UIViewController>(creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
		let storyboard = UIStoryboard(name: rawValue, bundle: nil)
		guard let vc = storyboard.instantiateInitialViewController(creator: creator) as? T else {
			let error = "Can't initiate start UIViewController for \(rawValue) storyboard"
			logError(message: error)
			fatalError(error)
		}
		return vc
	}
}
