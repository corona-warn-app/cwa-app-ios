////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMNHCViewModel {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
		self.restService = RestService()
	}

	// MARK: - Internal

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
		case .appConfig:
			return DMButtonCellViewModel(
				text: "appConfig",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					
					let resource = ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS>(.appConfiguration)
					self?.restService.load(resource: resource) { result in
						
						switch result {
						
						case let .success(model):
							print(model?.appFeatures)
							print("HTTP CALL SUCCESS")
						case let .failure(error):
							print("HTTP CALL FAIL")
						}
					}
				}
			)
		case .otpEdusAuthorization:
			return DMButtonCellViewModel(
				text: "otpEdusAuthorization",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					
				}
			)
		case .traceWarningPackageDiscovery:
			return DMButtonCellViewModel(
				text: "traceWarningPackageDiscovery",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					
				}
			)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case appConfig
		case otpEdusAuthorization
		case traceWarningPackageDiscovery
	}

	private let store: Store
	private let restService: Service
}
#endif
