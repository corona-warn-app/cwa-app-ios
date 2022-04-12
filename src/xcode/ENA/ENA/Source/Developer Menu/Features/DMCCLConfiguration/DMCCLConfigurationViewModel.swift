////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit
import CertLogic

final class DMCCLConfigurationViewModel {

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
		case .forceUpdateDescription:
			return DMStaticTextCellViewModel(
				staticText: "If this toggle is activated, the CCL Configuration and Booster Notification rules are updated independently from other constraints (update once a day etc.). This happens e.g. every time the app is moved from background into foreground. The app is killed when the switch is toggled.",
				font: .enaFont(for: .subheadline),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .center
			)
		case .forceUpdateCCLConfiguration:
			return DMSwitchCellViewModel(
				labelText: "Force-update CCL Configuration",
				isOn: {
					return UserDefaults.standard.bool(forKey: CCLConfigurationResource.keyForceUpdateCCLConfiguration)
				},
				toggle: {
					let forceUpdate = !UserDefaults.standard.bool(forKey: CCLConfigurationResource.keyForceUpdateCCLConfiguration)
					UserDefaults.standard.setValue(forceUpdate, forKey: CCLConfigurationResource.keyForceUpdateCCLConfiguration)
					Log.info("Force-update CCL Configuration: \(forceUpdate)")
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						exit(0)
					}
				})
		}
	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case forceUpdateDescription
		case forceUpdateCCLConfiguration
	}
	
	private var loadedFromCache: Bool?
}
#endif
