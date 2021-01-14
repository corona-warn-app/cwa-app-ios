//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeTextItemViewModel: HomeItemViewModel {

	// MARK: - Protocol HomeItemViewModel

	let ViewType: HomeItemViewAny.Type = HomeTextItemView.self

	// MARK: - Internal

	let title: String
	let titleColor: UIColor
	let color: UIColor
	let separatorColor: UIColor

}
