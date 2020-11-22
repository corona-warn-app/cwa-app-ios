//
// 🦠 Corona-Warn-App
//

import Foundation

class HomeTestResultLoadingCellConfigurator: CollectionViewCellConfigurator {

	func configure(cell: HomeTestResultLoadingCell) {
		cell.setupCell()
		cell.title.text = AppStrings.Home.resultCardLoadingTitle
		cell.body.text = AppStrings.Home.resultCardLoadingBody
		cell.button.isEnabled = false
		cell.button.setTitle(AppStrings.Home.resultCardShowResultButton, for: .disabled)
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		// this class has no stored properties, that's why hash function is empty here
	}

	static func == (lhs: HomeTestResultLoadingCellConfigurator, rhs: HomeTestResultLoadingCellConfigurator) -> Bool {
		// instances of this class have no differences between each other
		true
	}
}
