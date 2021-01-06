//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

class EUSettingsViewController: DynamicTableViewController {

	// MARK: - Public Attributes.

	var appConfigurationProvider: AppConfigurationProviding

	// MARK: - Private Attributes

	private var viewModel = EUSettingsViewModel()
	private var subscriptions = [AnyCancellable]()

	init(appConfigurationProvider: AppConfigurationProviding) {
		self.appConfigurationProvider = appConfigurationProvider

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View life cycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	// MARK: - View setup methods.

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		setupTableView()
		setupBackButton()
		setupDataSource()
	}

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.euSettingsModel()
		tableView.register(
			DynamicTableViewIconCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.flagCell.rawValue
		)

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
	}

	// MARK: Data Source setup methods.

	private func setupDataSource() {
		appConfigurationProvider.appConfiguration().sink { [weak self] configuration in
			let supportedCountryIDs = configuration.supportedCountries
			let supportedCountries = supportedCountryIDs.compactMap { Country(countryCode: $0) }
			self?.viewModel = EUSettingsViewModel(countries: supportedCountries)
			self?.reloadCountrySection()
		}.store(in: &subscriptions)
	}

	private func reloadCountrySection() {
		dynamicTableViewModel = viewModel.euSettingsModel()
		tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
	}
}

extension EUSettingsViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case flagCell
		case roundedCell
	}
}

extension DynamicCell {
	static func euCell(cellModel: EUSettingsViewModel.CountryModel) -> Self {
		.icon(cellModel.country.flag,
			  text: .string(cellModel.country.localizedName),
			  tintColor: nil,
			  style: .body,
			  iconWidth: 32,
			  action: .none,
			  configure: { _, cell, _ in
			cell.contentView.layoutMargins.left = 32
			cell.contentView.layoutMargins.right = 32
		})
	}

	static func emptyCell() -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.roundedCell,
			action: .none,
			accessoryAction: .none) { _, cell, _ in
				if let roundedCell = cell as? DynamicTableViewRoundedCell {
					roundedCell.configure(
						title: NSMutableAttributedString(string: AppStrings.ExposureNotificationSetting.euEmptyErrorTitle),
						titleStyle: .title2,
						body: NSMutableAttributedString(string: AppStrings.ExposureNotificationSetting.euEmptyErrorDescription),
						textColor: .textPrimary1,
						bgColor: .separator,
						icons: [
							UIImage(named: "Icons_MobileDaten"),
							UIImage(named: "Icon_Wifi")]
							.compactMap { $0 },
						buttonTitle: AppStrings.ExposureNotificationSetting.euEmptyErrorButtonTitle) {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}
				}
			}
	}
}
