////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit
import CertLogic

final class DMHealthCertificateMigrationViewModel {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
	}

	// MARK: - Internal

	var viewController: UIViewController?
	var refreshTableView: (IndexSet) -> Void = { _ in }

	var numberOfSections: Int {
		TableViewSections.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		guard TableViewSections.allCases.indices.contains(section) else {
			return 0
		}
		// at the moment we assume one cell per section only
		return 1
	}

	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}

		switch section {
		case .currentMigrationNumber:
			let currentMigrationNumber = store.healthCertifiedPersonsVersion ?? 0
			return DMStaticTextCellViewModel(
				staticText: "Current health certificates migration number: \(currentMigrationNumber)",
				font: .enaFont(for: .headline),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .left
			)
		case .quitHint:
			return DMStaticTextCellViewModel(
				staticText: "You can set below one new migration number. After you typed a number, the app will close itself.",
				font: .enaFont(for: .subheadline),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .center
			)
		case .setMigrationNumber:
			return DMTextFieldCellViewModel(
				labelText: "Change version to: ",
				textFieldDidChange: { [weak self] number in
					guard let number = number.int else {
						Log.warning("The entered string is not a number")
						return
					}
					self?.store.healthCertifiedPersonsVersion = number
					Log.info("healthCertifiedPersonsVersion set to: \(number). Force quit now.")
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						exit(0)
					}
				}
			)
		}
	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case currentMigrationNumber
		case quitHint
		case setMigrationNumber
	}

	private let store: Store

}
#endif
