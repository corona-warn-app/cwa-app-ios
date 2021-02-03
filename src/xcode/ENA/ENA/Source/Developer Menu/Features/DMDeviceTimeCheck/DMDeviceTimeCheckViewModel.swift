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

	// MARK: - Internal

	enum Sections: Int, CaseIterable {
		case deviceTimeCheckState
		case timestampLastChange
		case killDeviceTimeCheck
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
		case .deviceTimeCheckState:
			let status = String(describing: store.deviceTimeCheckResult)
			return DMKeyValueCellViewModel(key: "Time Check state:", value: status)

		case .timestampLastChange:
			let timestampString = DateFormatter.localizedString(from: store.deviceTimeLastStateChange, dateStyle: .medium, timeStyle: .medium)
			return DMKeyValueCellViewModel(key: "Last state change:", value: timestampString)

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
