////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit
import CertLogic

final class DMCCLConfigurationViewModel {

	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding
	) {
		self.restService = restServiceProvider
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
	
	// swiftlint:disable cyclomatic_complexity
	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}

		switch section {
			
		case .getCall:
			return DMButtonCellViewModel(
				text: "Call GET CLL Configuration",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.restService.load(CCLConfigurationResource()) { result in
						DispatchQueue.main.async {
							switch result {
							case let .success(model):
								Log.info("CCL Config successfull called.")
								Log.info("CCL Config isLoadedFromCache: \(model.metaData.loadedFromCache)")
								Log.info("CCL Config headers: \(model.metaData.headers)")
							case let .failure(error):
								Log.error("CCL Config call failure with: \(error)", error: error)
							}
						}
					}
				}
			)
			
		case .forceUpdate:
			return DMSwitchCellViewModel(
				labelText: "Ignore Once a day (Force update)",
				isOn: {
					return UserDefaults.standard.bool(forKey: CCLConfigurationResource.keyForceUpdate)
					
				},
				toggle: {
					let forceUpdate = UserDefaults.standard.bool(forKey: CCLConfigurationResource.keyForceUpdate)
					UserDefaults.standard.setValue(!forceUpdate, forKey: CCLConfigurationResource.keyForceUpdate)
					Log.info("Ignore Once a day fetch for cllConfig: \(!forceUpdate)")
				})

		case .statusCached:
			return DMButtonCellViewModel(
				text: "Was CCL Config loaded from cache:",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.restService.load(AppConfigurationResource()) { result in
						DispatchQueue.main.async {
							switch result {
							case .success:
								Log.info("New HTTP Call for AppConfig successful")
							case .failure:
								Log.error("New HTTP Call for AppConfig failed")
							}
						}
					}
				}
			)
		}
	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case getCall
		case forceUpdate
		case statusCached
	}

	private let restService: RestServiceProviding
	
	private var loadedFromCache: Bool
}
#endif
