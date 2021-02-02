//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMDeviceTimeCheckViewModel {

	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Overrides

	// MARK: - Public

	// MARK: - Internal

	enum menuItems: Int, CaseIterable {
		case deviceTimeCheckState
		case killDeviceTimeCheck
	}

	let itemsCount: Int = 1

	var numberOfSections: Int {
		return menuItems.allCases.count
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = menuItems(rawValue: indexPath.section) else {
			fatalError("Invalid tableview section")
		}
		switch section {
		case .deviceTimeCheckState:
			return DMKeyValueCellViewModel(key: "Time Check state:", value: "unknown")

		case .killDeviceTimeCheck:
			return DMSwitchCellViewModel(
				labelText: "Disable device time check",
				isOn: { [store] in
					store.dmKillDeviceTimeCheck
				}, toggle: { [store] in
					store.dmKillDeviceTimeCheck.toggle()
					Log.info("Device time check: \(store.dmKillDeviceTimeCheck ? "disabled" :"enabled")")
				})
		}
	}

	// MARK: - Private
	
	private let store: Store


}

#endif
