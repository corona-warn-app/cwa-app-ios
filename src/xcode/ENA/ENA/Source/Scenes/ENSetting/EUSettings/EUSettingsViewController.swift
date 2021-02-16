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
	private var applicationDidBecomeActiveObserver: NSObjectProtocol?
	private var appConfigCancellable: AnyCancellable?

	// MARK: Deinit
	
	deinit {
		if let observer = applicationDidBecomeActiveObserver {
			NotificationCenter.default.removeObserver(observer)
		}
		appConfigCancellable?.cancel()
	}
	
	// MARK: - Init
	
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
		setupObservers()
		setupDataSource(forceFetch: false)
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

	private func setupObservers() {
		applicationDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
			guard let self = self else { return }
			// reload country list if empty
			if self.viewModel.countryModels?.isEmpty == true {
				self.appConfigCancellable?.cancel()
				self.setupDataSource(forceFetch: true)
			}
		}
	}
	
	private func setupDataSource(forceFetch: Bool) {
		appConfigCancellable = appConfigurationProvider
			.appConfiguration(forceFetch: forceFetch)
			.map({ config -> [Country] in
				let supportedCountries = config.supportedCountries.compactMap({ Country(countryCode: $0) })
				return supportedCountries.sortedByLocalizedName
			})
			.map({ countries -> EUSettingsViewModel in
				return EUSettingsViewModel(countries: countries)
			})
			.sink { [weak self] model in
				self?.viewModel = model
				self?.dynamicTableViewModel = model.euSettingsModel()
				self?.tableView.reloadData()
			}
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
