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
				staticText: "Reset will clear the DSC list and refresh will update the list without time limits",
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
					Log.info("trigger refresh here")
				}
			)

		case .reset:
			return DMButtonCellViewModel(
				text: "Reset DSC lists",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					Log.info("trigger reset here")
				}
			)
		}
	}

	// MARK: - Private
	
	private let store: Store

}

#endif
