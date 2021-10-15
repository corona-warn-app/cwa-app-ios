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
		self.restService = RestServiceProvider()
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
					// Example of building a request without request body but with response body.
					let locationResource = AppConfigurationLocationResource()
					let sendResource = EmptySendResource<Any>()
					let receiveResource = ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>()

					self?.restService.load(locationResource, sendResource, receiveResource) { result in
						switch result {
						case .success:
							Log.info("New HTTP Call for AppConfig successful")
						case .failure:
							Log.error("New HTTP Call for AppConfig failed")
						}
					}
				}
			)
		case .otpEdusAuthorization:
			return DMButtonCellViewModel(
				text: "validationOnboardedCountries",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					
					// Example of building a request without request body but with response body.
					let locationResource = ValidationOnboardedCountriesLocationResource(isFake: false)
					let sendResource = EmptySendResource<Any>()
					// TODO Create ReceiveResource of Type....String?
					let receiveResource = JSONReceiveResource<[String]>()

					self?.restService.load(locationResource, sendResource, receiveResource) { result in
						switch result {
						case .success:
							Log.info("New HTTP Call for validationOnboardedCountries successful")
						case .failure:
							Log.error("New HTTP Call for validationOnboardedCountries failed")
						}
					}
				}
			)
		case .traceWarningPackageDiscovery:
			return DMButtonCellViewModel(
				text: "Registration Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					let location = RegistrationTokenLocationResource(isFake: false)
					let sendModel = KeyModel(key: "EKRWNPPGAB", keyType: "TELETAN")
					let sendResource = JSONSendResource<KeyModel>(sendModel)
					let receiveResource = EmptyReceiveResource<Any>()
					self?.restService.load(location, sendResource, receiveResource) { result in
						switch result {
						case .success:
							Log.info("New HTTP Call for Registration Token successful")
						case .failure:
							Log.error("New HTTP Call for Registration Token failed")
						}
					}
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
	private let restService: RestServiceProviding
}
#endif
