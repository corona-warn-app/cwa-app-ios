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
		case .refresh:
			return DMStaticTextCellViewModel(
				staticText: "Changes will apply immediately",
				font: .enaFont(for: .subheadline),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .center
			)

		case .reset:
			return DMSwitchCellViewModel(
				labelText: "Unencrypted event checkins",
				isOn: { [store] in
					store.unencryptedCheckinsEnabled
				}, toggle: { [store] in
					store.unencryptedCheckinsEnabled.toggle()
					Log.info("Unencrypted event checkins: \(store.unencryptedCheckinsEnabled ? "disabled" :"enabled")")
				})
		}
	}

	// MARK: - Private
	
	private let store: Store

}

#endif
