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
		self.restService = RestServiceProvider(cache: KeyValueCacheFake())
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
					self?.restService.load(AppConfigurationResource()) { result in
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
					self?.restService.load(ValidationOnboardedCountriesResource()) { result in
						switch result {
						case .success:
							Log.info("New HTTP Call for validationOnboardedCountries successful")
						case .failure:
							Log.error("New HTTP Call for validationOnboardedCountries failed")
						}
					}
				}
			)
		case .registerTeleTAN:
			return DMButtonCellViewModel(
				text: "Register TeleTan",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					DispatchQueue.main.async { [weak self] in
						self?.showAskTANAlertAndSubmit()
					}
				}
			)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case appConfig
		case otpEdusAuthorization
		case registerTeleTAN
	}

	private let store: Store
	private let restService: RestServiceProviding

	private func showAskTANAlertAndSubmit() {
		let alert = UIAlertController(title: "TELETAN", message: "Please enter TeleTAN", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "TeleTan"
		}
		alert.addAction(
			UIAlertAction(
				title: "Cancel", style: .cancel, handler: nil
			)
		)
		alert.addAction(
			UIAlertAction(
				title: "Ok",
				style: .default,
				handler: { [weak self] _ in
					guard let textField = alert.textFields?.first,
						  let teleTan = textField.text,
						  !teleTan.isEmpty else {
							  Log.error("no textfield found")
							  return
						  }
					let resource = TeleTanResource(
						sendModel: KeyModel(
							key: teleTan,
							keyType: .teleTan,
							keyDob: nil
						)
					)
					self?.restService.load(resource) { result in
						switch result {
						case .success:
							Log.info("New HTTP Call for Registration Token successful")
						case let .failure(serviceError):
							if case let .receivedResourceError(teleTanError) = serviceError {
								switch teleTanError {
								case .teleTanAlreadyUsed:
									Log.error(".teleTanAlreadyUsed")
								case .qrAlreadyUsed:
									Log.error(".qrCodeInvalid")
								}
							}

						}
					}

				}
			)
		)
		viewController?.present(alert, animated: true)
	}

}
#endif
