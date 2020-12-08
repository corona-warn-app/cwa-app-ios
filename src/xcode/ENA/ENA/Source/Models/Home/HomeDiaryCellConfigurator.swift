//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class HomeDiaryCellConfigurator: CollectionViewCellConfigurator {

	var primaryAction: (() -> Void)?

	func configure(cell: HomeTestResultCollectionViewCell) {
		cell.delegate = self

		cell.configure(
			title: AppStrings.Home.diaryCardTitle,
			description: AppStrings.Home.diaryCardBody,
			button: AppStrings.Home.diaryCardButton,
			image: UIImage(named: "Illu_Diary"),
			accessibilityIdentifier: AccessibilityIdentifiers.Home.diaryCardButton
		)
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine("")
	}

	static func == (lhs: HomeDiaryCellConfigurator, rhs: HomeDiaryCellConfigurator) -> Bool {
		true
	}

}

extension HomeDiaryCellConfigurator: HomeTestResultCollectionViewCellDelegate {
	func testResultCollectionViewCellPrimaryActionTriggered(_ collectionViewCell: HomeTestResultCollectionViewCell) {
		primaryAction?()
	}
}
