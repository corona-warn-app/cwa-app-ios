//
// 🦠 Corona-Warn-App
//
#if !RELEASE

import Foundation
import UIKit

final class DMTicketValidationViewModel {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
		self.toggleAllowList = true
	}

	// MARK: - Internal

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
		case .toggleAllowList:
			return DMSwitchCellViewModel(
				labelText: "Allowlist check:",
				isOn: { [weak self] in
					guard let self = self else { return false }
					return self.toggleAllowList
				},
				toggle: { [weak self] in
					guard let self = self else { return }
					self.toggleAllowList.toggle()
				}
			)

		}
	}

	// MARK: - Private

	enum TableViewSections: Int, CaseIterable {
		case toggleAllowList
	}

	private let store: Store
	private var toggleAllowList: Bool
}

#endif
