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

	var itemsCount: Int {
		return menuItems.allCases.count
	}

	func cellViewModel(for indexPath: IndexPath) -> DMSwitchCellViewModel {
		guard let item = menuItems(rawValue: indexPath.row) else {
			fatalError("failed to create cellViewModel")
		}
		switch item {

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

	private enum menuItems: Int, CaseIterable {
		case killDeviceTimeCheck
	}

}

#endif
