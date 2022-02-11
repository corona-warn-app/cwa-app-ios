////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit
import CertLogic

final class DMNHCViewModel {

	// MARK: - Init

	init(
		store: Store,
		cache: KeyValueCaching
	) {
		self.store = store
		self.restService = RestServiceProvider(cache: cache)
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
			
		case .cclConfiguration:
			return DMButtonCellViewModel(
				text: "cclConfiguration",
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
			
		case .dccRules:
			return DMButtonCellViewModel(
				text: "dccRules",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.showDCCRulesSheetAndSubmit()
				}
			)

		case .appConfig:
			return DMButtonCellViewModel(
				text: "appConfig",
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
		case .validationOnboardedCountries:
			return DMButtonCellViewModel(
				text: "validationOnboardedCountries",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.restService.load(ValidationOnboardedCountriesResource()) { result in
						DispatchQueue.main.async {
							switch result {
							case let .success(countriesModel):
								Log.info("New HTTP Call for validationOnboardedCountries successful. Countries: \(countriesModel.countries)")
							case let .failure(error):
								Log.error("New HTTP Call for validationOnboardedCountries failed with error: \(error)")
							}
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
		case cclConfiguration
		case dccRules
		case appConfig
		case validationOnboardedCountries
		case registerTeleTAN
	}

	private let store: Store
	private let restService: RestServiceProviding

	private func showDCCRulesSheetAndSubmit() {
		let sheet = UIAlertController(title: "Type", message: "select ruletype", preferredStyle: .actionSheet)
		HealthCertificateValidationRuleType.allCases.forEach { ruleType in
			sheet.addAction(
				UIAlertAction(
					title: ruleType.urlPath,
					style: .default,
					handler: { [weak self] _ in
						Log.info("Did select \(ruleType.urlPath)")
						self?.performDccRulesRequest(ruleType)
					}
				)
			)
		}
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.present(sheet, animated: true)
		}
	}

	private func performDccRulesRequest(_ ruleType: HealthCertificateValidationRuleType) {
		let resource = DCCRulesResource(isFake: false, ruleType: ruleType)
		restService.load(resource) { result in
			DispatchQueue.main.async {
				switch result {
				case .success:
					Log.info("New HTTP Call for dccRule \(ruleType.urlPath) successful")
				case .failure:
					Log.error("New HTTP Call for dccRule \(ruleType.urlPath) failed")
				}
			}
		}

	}

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
						sendModel: TeleTanSendModel(
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
