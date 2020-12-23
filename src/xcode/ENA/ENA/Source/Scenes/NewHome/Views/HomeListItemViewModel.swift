//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeListItemViewModel: HomeItemViewModel {

	// MARK: - Protocol HomeItemViewModel

	let ViewType: HomeItemViewAny.Type = HomeListItemView.self

	// MARK: - Internal

	let text: String
	let textColor: UIColor

}
