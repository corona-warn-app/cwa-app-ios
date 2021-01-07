//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeImageItemViewModel: HomeItemViewModel {

	// MARK: - Protocol HomeItemViewModel

	let ViewType: HomeItemViewAny.Type = HomeImageItemView.self

	// MARK: - Internal

	let title: String
	let titleColor: UIColor
	let iconImageName: String
	let iconTintColor: UIColor
	let color: UIColor
	let separatorColor: UIColor

	let containerInsets: UIEdgeInsets?

}
