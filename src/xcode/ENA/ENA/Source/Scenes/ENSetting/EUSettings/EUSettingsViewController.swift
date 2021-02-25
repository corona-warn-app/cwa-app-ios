//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

class EUSettingsViewController: DynamicTableViewController {

	// MARK: - Init

	init(appConfigurationProvider: AppConfigurationProviding) {
		self.appConfigurationProvider = appConfigurationProvider
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Deinit

	deinit {
		if let observer = applicationDidBecomeActiveObserver {
			NotificationCenter.default.removeObserver(observer)
		}
		appConfigCancellable?.cancel()
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	// MARK: - Internal

	var appConfigurationProvider: AppConfigurationProviding

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case flagCell
		case roundedCell
	}

	// MARK: - Private

	private var viewModel = EUSettingsViewModel()
	private var applicationDidBecomeActiveObserver: NSObjectProtocol?
	private var appConfigCancellable: AnyCancellable?

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

	private func setupObservers() {
		applicationDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
			guard let self = self,
				  self.viewModel.countries.isEmpty else {
				Log.debug("country list is not empty we don't need to reload", log: .default)
				return
			}
			self.appConfigCancellable?.cancel()
			self.setupDataSource(forceFetch: true)
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
