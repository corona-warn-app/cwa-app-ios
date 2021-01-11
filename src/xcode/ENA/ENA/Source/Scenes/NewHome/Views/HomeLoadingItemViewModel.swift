//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeLoadingItemViewModel: HomeItemViewModel {

	// MARK: - Protocol HomeItemViewModel

	let ViewType: HomeItemViewAny.Type = HomeLoadingItemView.self

	// MARK: - Internal

	let title: String
	let titleColor: UIColor
	let isActivityIndicatorOn: Bool
	let color: UIColor
	let separatorColor: UIColor

}
