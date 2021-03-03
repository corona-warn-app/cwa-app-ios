////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMInstallationDateViewModel {

	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Overrides

	// MARK: - Internal

	enum Sections: Int, CaseIterable {
		case installationDate
	}

	var numberOfSections: Int {
		Sections.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		1
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableview section")
		}

		switch section {
		case .installationDate:
			return DMDatePickerCellViewModel(
				title: "Installation Date",
				datePickerMode: .date,
				date: store.appFirstStartDate ?? Date()
			)
		}
	}

	// MARK: - Private

	private let store: Store

}

#endif
