//
// 🦠 Corona-Warn-App
//

import UIKit

enum AppStoryboard: String {
	case home = "Home"
	case onboarding = "Onboarding"
	case exposureNotificationSetting = "ExposureNotificationSetting"
	case settings = "Settings"
	case developerMenu = "DeveloperMenu"
	case inviteFriends = "InviteFriends"
	case exposureDetection = "ExposureDetection"

	var instance: UIStoryboard {
		UIStoryboard(name: rawValue, bundle: nil)
	}

	func initiate<T: UIViewController>(viewControllerType: T.Type, creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
		let storyboard = UIStoryboard(name: rawValue, bundle: nil)
		let viewControllerIdentifier = viewControllerType.stringName()
		guard let vc = storyboard.instantiateViewController(identifier: viewControllerIdentifier, creator: creator) as? T else {
			let error = "Can't initiate \(viewControllerIdentifier) for \(rawValue) storyboard"
			Log.error(error, log: .ui)
			fatalError(error)
		}
		return vc
	}

	func initiateInitial<T: UIViewController>(creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
		let storyboard = UIStoryboard(name: rawValue, bundle: nil)
		guard let vc = storyboard.instantiateInitialViewController(creator: creator) as? T else {
			let error = "Can't initiate start UIViewController for \(rawValue) storyboard"
			Log.error(error, log: .ui)
			fatalError(error)
		}
		return vc
	}
}
