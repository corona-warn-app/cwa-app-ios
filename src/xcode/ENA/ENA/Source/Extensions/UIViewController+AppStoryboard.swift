//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIViewController {
	static func initiate(for storyboard: AppStoryboard, creator: ((NSCoder) -> UIViewController?)? = nil) -> Self {
		storyboard.initiate(viewControllerType: self, creator: creator)
	}
}
