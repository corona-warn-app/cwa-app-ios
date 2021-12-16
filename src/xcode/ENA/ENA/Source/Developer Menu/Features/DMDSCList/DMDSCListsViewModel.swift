//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMDSCListsViewModel {

	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Internal

	enum Sections: Int, CaseIterable {
		case notice
		case refresh
		case reset
	}

	var presentResetAlert: ((UIAlertAction, UIAlertAction) -> Void)?
	var presentRefreshAlert: ((UIAlertAction, UIAlertAction) -> Void)?

	let itemsCount: Int = 1

	var numberOfSections: Int {
		return Sections.allCases.count
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableview section")
		}
		switch section {
		case .notice:
			return DMStaticTextCellViewModel(
				staticText: "Helper to reset or trigger a refresh of the dsc list. Reset requires a restart. Refresh will happen after the app was in background and reaches foreground mode again.",
				font: .enaFont(for: .subheadline),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .center
			)

		case .refresh:
			return DMButtonCellViewModel(
				text: "Refresh DSC lists",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					guard var metaData = self.store.dscList else {
						Log.info("no meta data found to manipulate", log: .debugMenu)
						return
					}
					metaData.timestamp = Date(timeIntervalSinceNow: -DSCListProvider.updateInterval)

					self.presentRefreshAlert?(
						UIAlertAction(
							title: "yes, refresh it!",
							style: .destructive,
							handler: { [weak self] _ in
								Log.info("Refresh DSCList.", log: .debugMenu)
								self?.store.dscList = metaData
							}
						),
						UIAlertAction(
							title: "no, keep them",
							style: .default
						)
					)
				}
			)

		case .reset:
			return DMButtonCellViewModel(
				text: "Reset DSC lists",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					self.presentResetAlert?(
						UIAlertAction(
							title: "Clean it!",
							style: .destructive,
							handler: { [weak self] _ in
								Log.info("Reset DSCList.", log: .debugMenu)
								self?.store.dscList = nil
								exit(0)
							}
						),
						UIAlertAction(
							title: "no, keep them",
							style: .default
						)
					)
				}
			)
		}
	}

	// MARK: - Private
	
	private let store: Store

}

#endif
