////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

// swiftlint:disable:next type_body_length
class HomeTableViewController: UITableViewController, NavigationBarOpacityDelegate {

	// MARK: - Init

	init(
		viewModel: HomeTableViewModel,
		appConfigurationProvider: AppConfigurationProviding,
		route: Route?,
		onInfoBarButtonItemTap: @escaping () -> Void,
		onExposureLoggingCellTap: @escaping (ENStateHandler.State) -> Void,
		onRiskCellTap: @escaping (HomeState) -> Void,
		onInactiveCellButtonTap: @escaping (ENStateHandler.State) -> Void,
		onTestRegistrationCellTap: @escaping () -> Void,
		onStatisticsInfoButtonTap: @escaping () -> Void,
		onTraceLocationsCellTap: @escaping () -> Void,
		onInviteFriendsCellTap: @escaping () -> Void,
		onFAQCellTap: @escaping () -> Void,
		onAppInformationCellTap: @escaping () -> Void,
		onSettingsCellTap: @escaping (ENStateHandler.State) -> Void,
		showTestInformationResult: @escaping (Result<CoronaTestQRCodeInformation, QRCodeError>) -> Void,
		onCreateHealthCertificateTap: @escaping () -> Void,
		onCertifiedPersonTap: @escaping (HealthCertifiedPerson) -> Void
	) {
		self.viewModel = viewModel
		self.appConfigurationProvider = appConfigurationProvider
		self.route = route
		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onExposureLoggingCellTap = onExposureLoggingCellTap
		self.onRiskCellTap = onRiskCellTap
		self.onInactiveCellButtonTap = onInactiveCellButtonTap
		self.onTestRegistrationCellTap = onTestRegistrationCellTap
		self.onStatisticsInfoButtonTap = onStatisticsInfoButtonTap
		self.onTraceLocationsCellTap = onTraceLocationsCellTap
		self.onInviteFriendsCellTap = onInviteFriendsCellTap
		self.onFAQCellTap = onFAQCellTap
		self.onAppInformationCellTap = onAppInformationCellTap
		self.onSettingsCellTap = onSettingsCellTap
		self.showTestInformationResult = showTestInformationResult
		self.onCreateHealthCertificateTap = onCreateHealthCertificateTap
		self.onCertifiedPersonTap = onCertifiedPersonTap

		super.init(style: .grouped)

		viewModel.$riskAndTestResultsRows
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadSections([HomeTableViewModel.Section.riskAndTestResults.rawValue], with: .none)
				self?.viewModel.isUpdating = false
			}
			.store(in: &subscriptions)
		
		viewModel.$healthCertifiedPersons
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadSections([HomeTableViewModel.Section.healthCertificate.rawValue], with: .none)
				self?.viewModel.isUpdating = false
			}
			.store(in: &subscriptions)

		viewModel.$testResultLoadingError
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] error in
				guard let self = self, let error = error else { return }

				self.viewModel.testResultLoadingError = nil

				self.alertError(
					message: error.localizedDescription,
					title: AppStrings.Home.TestResult.resultCardLoadingErrorTitle
				)
			}
			.store(in: &subscriptions)

		viewModel.state.$statisticsLoadingError
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] statisticsLoadingError in
				guard let self = self, statisticsLoadingError != nil else { return }

				self.viewModel.state.statisticsLoadingError = nil

				self.alertError(
					message: AppStrings.Statistics.error,
					title: nil
				)
			}
			.store(in: &subscriptions)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBarButtonItems()
		setupTableView()

		navigationItem.largeTitleDisplayMode = .automatic
		tableView.backgroundColor = .enaColor(for: .darkBackground)

		NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterResumingFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: NSNotification.Name.NSCalendarDayChanged, object: nil)

		refreshUI()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		/// preload expensive and updating cells to increase initial scrolling performance (especially of the statistics cell) and prevent animation on initial appearance
		if statisticsCell == nil {
			riskCell = riskCell(forRowAt: IndexPath(row: 0, section: HomeTableViewModel.Section.riskAndTestResults.rawValue))
			pcrTestResultCell = testResultCell(forRowAt: IndexPath(row: 1, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .pcr)
			pcrTestShownPositiveResultCell = shownPositiveTestResultCell(forRowAt: IndexPath(row: 1, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .pcr)
			antigenTestResultCell = testResultCell(forRowAt: IndexPath(row: 2, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .antigen)
			antigenTestShownPositiveResultCell = shownPositiveTestResultCell(forRowAt: IndexPath(row: 2, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .antigen)
			statisticsCell = statisticsCell(forRowAt: IndexPath(row: 0, section: HomeTableViewModel.Section.statistics.rawValue))
		}

		/** navigationbar is a shared property - so we need to trigger a resizing because others could have set it to true*/
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.sizeToFit()

		viewModel.state.requestRisk(userInitiated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		#if DEBUG
		if isUITesting && UserDefaults.standard.string(forKey: "showTestResultCards") == "YES" {
			tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .top, animated: false)
		}
		#endif
		
		showDeltaOnboardingAndAlertsIfNeeded()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	// swiftlint:disable:next cyclomatic_complexity
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			return exposureLoggingCell(forRowAt: indexPath)
		case .riskAndTestResults:
			switch viewModel.riskAndTestResultsRows[indexPath.row] {
			case .risk:
				return riskCell(forRowAt: indexPath)
			case .pcrTestResult(let testState):
				switch testState {
				case .default:
					return testResultCell(forRowAt: indexPath, coronaTestType: .pcr)
				case .positiveResultWasShown:
					return shownPositiveTestResultCell(forRowAt: indexPath, coronaTestType: .pcr)
				}

			case .antigenTestResult(let testState):
				switch testState {
				case .default:
					return testResultCell(forRowAt: indexPath, coronaTestType: .antigen)
				case .positiveResultWasShown:
					return shownPositiveTestResultCell(forRowAt: indexPath, coronaTestType: .antigen)
				}
			}
		case .testRegistration:
			return testRegistrationCell(forRowAt: indexPath)
		case .statistics:
			return statisticsCell(forRowAt: indexPath)
		case .traceLocations:
			return traceLocationsCell(forRowAt: indexPath)
		case .infos:
			return infoCell(forRowAt: indexPath)
		case .settings:
			return infoCell(forRowAt: indexPath)

		case .healthCertificate:
			return healthCertificateCell(forRowAt: indexPath)
		case .createHealthCertificate:
			return vaccinationRegistrationCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard HomeTableViewModel.Section(rawValue: section) == .settings else {
			return UIView()
		}

		let headerView = UIView()
		headerView.backgroundColor = .enaColor(for: .separator)

		return headerView
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return viewModel.heightForHeader(in: section)
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if HomeTableViewModel.Section(rawValue: section) == .infos {
			let footerView = UIView()
			footerView.backgroundColor = .enaColor(for: .separator)

			return footerView
		} else if HomeTableViewModel.Section(rawValue: section) == .settings {
			let footerView = UIView()

			let colorView = UIView()
			colorView.backgroundColor = .enaColor(for: .separator)

			footerView.addSubview(colorView)
			colorView.translatesAutoresizingMaskIntoConstraints = false

			NSLayoutConstraint.activate([
				colorView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
				colorView.topAnchor.constraint(equalTo: footerView.topAnchor),
				colorView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
				// Extend the last footer view so the color is shown even when rubber banding the scroll view
				colorView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: UIScreen.main.bounds.height)
			])

			return footerView
		} else {
			return UIView()
		}
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return viewModel.heightForFooter(in: section)
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return viewModel.heightForRow(at: indexPath)
	}

	// MARK: - Protocol UITableViewDelegate
	
	// swiftlint:disable:next cyclomatic_complexity
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			onExposureLoggingCellTap(viewModel.state.enState)
		case .riskAndTestResults:
			switch viewModel.riskAndTestResultsRows[indexPath.row] {
			case .risk:
				onRiskCellTap(viewModel.state)
			case .pcrTestResult:
				viewModel.didTapTestResultCell(coronaTestType: .pcr)
			case .antigenTestResult:
				viewModel.didTapTestResultCell(coronaTestType: .antigen)
			}
		case .testRegistration:
			onTestRegistrationCellTap()
		case .statistics:
			break
		case .traceLocations:
			onTraceLocationsCellTap()
		case .infos:
			if indexPath.row == 0 {
				onInviteFriendsCellTap()
			} else {
				onFAQCellTap()
			}
		case .settings:
			if indexPath.row == 0 {
				onAppInformationCellTap()
			} else {
				onSettingsCellTap(viewModel.state.enState)
			}

		case .createHealthCertificate:
			onCreateHealthCertificateTap()

		case .healthCertificate:
			if let healthCertifiedPerson = viewModel.healthCertifiedPerson(at: indexPath) {
				onCertifiedPersonTap(healthCertifiedPerson)
			}

		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol NavigationBarOpacityDelegate

	var preferredNavigationBarOpacity: CGFloat {
		let alpha = (tableView.adjustedContentInset.top + tableView.contentOffset.y) / 32
		return max(0, min(alpha, 1))
	}

	// MARK: - Internal

	var route: Route?

	func scrollToTop(animated: Bool) {
		tableView.setContentOffset(.zero, animated: animated)
	}

	func showDeltaOnboardingAndAlertsIfNeeded() {
		self.showRouteIfNeeded(completion: {
			self.showDeltaOnboardingIfNeeded(completion: { [weak self] in
				self?.showInformationHowRiskDetectionWorksIfNeeded(completion: {
					self?.showBackgroundFetchAlertIfNeeded(completion: {
						self?.showRiskStatusLoweredAlertIfNeeded()
					})
				})
			})
		})
	}

	// MARK: - Private

	private let viewModel: HomeTableViewModel
	private let appConfigurationProvider: AppConfigurationProviding

	private let onInfoBarButtonItemTap: () -> Void
	private let onExposureLoggingCellTap: (ENStateHandler.State) -> Void
	private let onRiskCellTap: (HomeState) -> Void
	private let onInactiveCellButtonTap: (ENStateHandler.State) -> Void
	private let onTestRegistrationCellTap: () -> Void
	private let onStatisticsInfoButtonTap: () -> Void
	private let onTraceLocationsCellTap: () -> Void
	private let onInviteFriendsCellTap: () -> Void
	private let onFAQCellTap: () -> Void
	private let onAppInformationCellTap: () -> Void
	private let onSettingsCellTap: (ENStateHandler.State) -> Void
	private let showTestInformationResult: (Result<CoronaTestQRCodeInformation, QRCodeError>) -> Void
	private let onCreateHealthCertificateTap: () -> Void
	private let onCertifiedPersonTap: (HealthCertifiedPerson) -> Void

	private var deltaOnboardingCoordinator: DeltaOnboardingCoordinator?
	private var riskCell: UITableViewCell?
	private var pcrTestResultCell: UITableViewCell?
	private var pcrTestShownPositiveResultCell: UITableViewCell?
	private var antigenTestResultCell: UITableViewCell?
	private var antigenTestShownPositiveResultCell: UITableViewCell?
	private var statisticsCell: UITableViewCell?

	private var subscriptions = Set<AnyCancellable>()

	private func setupBarButtonItems() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Corona-Warn-App"), style: .plain, target: nil, action: nil)
		navigationItem.leftBarButtonItem?.customView = UIImageView(image: navigationItem.leftBarButtonItem?.image)
		navigationItem.leftBarButtonItem?.isAccessibilityElement = true
		navigationItem.leftBarButtonItem?.accessibilityTraits = .none
		navigationItem.leftBarButtonItem?.accessibilityLabel = AppStrings.Home.leftBarButtonDescription
		navigationItem.leftBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.leftBarButtonDescription

		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
	}

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: HomeExposureLoggingTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeExposureLoggingTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeRiskTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeRiskTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeHealthCertifiedPersonTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: HomeHealthCertifiedPersonTableViewCell.reuseIdentifier
		)
		tableView.register(
			UINib(nibName: String(describing: HomeHealthCertificateRegistrationTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeHealthCertificateRegistrationTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeTestResultTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeTestResultTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeShownPositiveTestResultTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeShownPositiveTestResultTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeTestRegistrationTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeTestRegistrationTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeStatisticsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeStatisticsTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeTraceLocationsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeTraceLocationsTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeInfoTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeInfoTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension

		/// Overestimate to fix auto layout warnings and fix a problem that showed the test cell behind other cells when opening app from the background in manual mode
		tableView.estimatedRowHeight = 500
	}

	private func animateChanges(of cell: UITableViewCell) {
		/// DispatchQueue prevents undefined behaviour in `visibleCells` while cells are being updated
		/// https://developer.apple.com/forums/thread/117537
		DispatchQueue.main.async { [self] in
			guard !viewModel.isUpdating, tableView.visibleCells.contains(cell) else {
				return
			}
			
			/// Animate the changed cell height
			tableView.performBatchUpdates(nil, completion: nil)

			/// Keep the other visible cells maskToBounds off during the animation to avoid flickering shadows due to them being cut off (https://stackoverflow.com/a/59581645)
			for cell in tableView.visibleCells {
				cell.layer.masksToBounds = false
				cell.contentView.layer.masksToBounds = false
			}
		}
	}

	private func exposureLoggingCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeExposureLoggingTableViewCell.self), for: indexPath) as? HomeExposureLoggingTableViewCell else {
			fatalError("Could not dequeue HomeExposureLoggingTableViewCell")
		}

		cell.configure(with: HomeExposureLoggingCellModel(state: viewModel.state))

		return cell
	}
	
	private func healthCertificateCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeHealthCertifiedPersonTableViewCell.self), for: indexPath) as? HomeHealthCertifiedPersonTableViewCell else {
			fatalError("Could not dequeue HomeHealthCertifiedPersonTableViewCell")
		}

		let healthCertifiedPerson = viewModel.healthCertifiedPersons[indexPath.row]
		let cellModel = HomeHealthCertifiedPersonCellModel(
			healthCertifiedPerson: healthCertifiedPerson,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(with: cellModel)

		return cell
	}

	private func riskCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		if let riskCell = riskCell {
			return riskCell
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeRiskTableViewCell.self), for: indexPath) as? HomeRiskTableViewCell else {
			fatalError("Could not dequeue HomeRiskTableViewCell")
		}

		let cellModel = HomeRiskCellModel(
			homeState: viewModel.state,
			onInactiveButtonTap: { [weak self] in
				guard let self = self else { return }

				self.onInactiveCellButtonTap(self.viewModel.state.enState)
			},
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(with: cellModel)

		riskCell = cell

		return cell
	}

	private func testResultCell(
		forRowAt indexPath: IndexPath,
		coronaTestType: CoronaTestType
	) -> UITableViewCell {
		switch coronaTestType {
		case .pcr:
			if let cell = pcrTestResultCell {
				return cell
			}
		case .antigen:
			if let cell = antigenTestResultCell {
				return cell
			}
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTestResultTableViewCell.self), for: indexPath) as? HomeTestResultTableViewCell else {
			fatalError("Could not dequeue HomeTestResultTableViewCell")
		}

		let cellModel = HomeTestResultCellModel(
			coronaTestType: coronaTestType,
			coronaTestService: viewModel.coronaTestService,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(
			with: cellModel,
			onPrimaryAction: { [weak self] in
				self?.viewModel.didTapTestResultButton(coronaTestType: coronaTestType)
			}
		)

		switch coronaTestType {
		case .pcr:
			pcrTestResultCell = cell
		case .antigen:
			antigenTestResultCell = cell
		}

		return cell
	}

	private func shownPositiveTestResultCell(
		forRowAt indexPath: IndexPath,
		coronaTestType: CoronaTestType
	) -> UITableViewCell {
		switch coronaTestType {
		case .pcr:
			if let cell = pcrTestShownPositiveResultCell {
				return cell
			}
		case .antigen:
			if let cell = antigenTestShownPositiveResultCell {
				return cell
			}
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeShownPositiveTestResultTableViewCell.self), for: indexPath) as? HomeShownPositiveTestResultTableViewCell else {
			fatalError("Could not dequeue HomeShownPositiveTestResultTableViewCell")
		}

		let cellModel = HomeShownPositiveTestResultCellModel(
			coronaTestType: coronaTestType,
			coronaTestService: viewModel.coronaTestService,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(
			with: cellModel,
			onPrimaryAction: { [weak self] in
				self?.viewModel.didTapTestResultButton(coronaTestType: coronaTestType)
			}
		)

		switch coronaTestType {
		case .pcr:
			pcrTestShownPositiveResultCell = cell
		case .antigen:
			antigenTestShownPositiveResultCell = cell
		}

		return cell
	}
	private func vaccinationRegistrationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeHealthCertificateRegistrationTableViewCell.self), for: indexPath) as? HomeHealthCertificateRegistrationTableViewCell else {
			fatalError("Could not dequeue HomeHealthCertificateRegistrationTableViewCell")
		}

		cell.configure(
			with: HomeHealthCertificateRegistrationCellModel(),
			onPrimaryAction: { [weak self] in
				self?.onCreateHealthCertificateTap()
			}
		)

		return cell
	}

	private func testRegistrationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTestRegistrationTableViewCell.self), for: indexPath) as? HomeTestRegistrationTableViewCell else {
			fatalError("Could not dequeue HomeTraceLocationsTableViewCell")
		}

		cell.configure(
			with: HomeTestRegistrationCellModel(),
			onPrimaryAction: { [weak self] in
				self?.onTestRegistrationCellTap()
			}
		)

		return cell
	}

	private func statisticsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		if let statisticsCell = statisticsCell {
			return statisticsCell
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeStatisticsTableViewCell.self), for: indexPath) as? HomeStatisticsTableViewCell else {
			fatalError("Could not dequeue HomeStatisticsTableViewCell")
		}

		cell.configure(
			with: HomeStatisticsCellModel(homeState: viewModel.state),
			onInfoButtonTap: { [weak self] in
				self?.onStatisticsInfoButtonTap()
			},
			onAccessibilityFocus: { [weak self] in
				self?.tableView.contentOffset.x = 0
				self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
			},
			onUpdate: { [weak self] in
				DispatchQueue.main.async { [weak self] in
					self?.tableView.reloadSections([HomeTableViewModel.Section.statistics.rawValue], with: .none)
				}
			}
		)

		statisticsCell = cell

		return cell
	}

	private func traceLocationsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTraceLocationsTableViewCell.self), for: indexPath) as? HomeTraceLocationsTableViewCell else {
			fatalError("Could not dequeue HomeTraceLocationsTableViewCell")
		}

		cell.configure(
			with: HomeTraceLocationsCellModel(),
			onPrimaryAction: { [weak self] in
				self?.onTraceLocationsCellTap()
			}
		)

		return cell
	}

	private func infoCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeInfoTableViewCell.self), for: indexPath) as? HomeInfoTableViewCell else {
			fatalError("Could not dequeue HomeInfoTableViewCell")
		}

		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .infos:
			if indexPath.row == 0 {
				cell.configure(with: HomeInfoCellModel(infoCellType: .inviteFriends))
			} else {
				cell.configure(with: HomeInfoCellModel(infoCellType: .faq))
			}
		case .settings:
			if indexPath.row == 0 {
				cell.configure(with: HomeInfoCellModel(infoCellType: .appInformation))
			} else {
				cell.configure(with: HomeInfoCellModel(infoCellType: .settings))
			}
		default:
			fatalError("Invalid section")
		}

		return cell
	}

	@IBAction private func infoButtonTapped() {
		onInfoBarButtonItemTap()
	}

	private func showRouteIfNeeded(completion: @escaping () -> Void) {
		defer {
			route = nil
		}

		// handle error -> show alert & trigger the chain
		guard case let .rapidAntigen(testResult) = route else {
			completion()
			return
		}
		showTestInformationResult(testResult)
	}

	private func showDeltaOnboardingIfNeeded(completion: @escaping () -> Void = {}) {
		guard deltaOnboardingCoordinator == nil else { return }

		appConfigurationProvider.appConfiguration().sink { [weak self] configuration in
			guard let self = self else { return }

			let supportedCountries = configuration.supportedCountries.compactMap({ Country(countryCode: $0) })

			/// As per feature requirement, the delta onboarding should appear with a slight delay of 0.5
			var delay = 0.5

			#if DEBUG
			if isUITesting {
				/// In UI Testing we need to increase the delay slightly again. Otherwise UI Tests fail.
				delay = 1.5
			}
			#endif

			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				let onboardings: [DeltaOnboarding] = [
					DeltaOnboardingV15(store: self.viewModel.store, supportedCountries: supportedCountries),
					DeltaOnboardingDataDonation(store: self.viewModel.store),
					DeltaOnboardingNewVersionFeatures(store: self.viewModel.store)
				]
				Log.debug("Delta Onboarding list size: \(onboardings.count)")

				self.deltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: self, onboardings: onboardings)
				self.deltaOnboardingCoordinator?.finished = { [weak self] in
					self?.deltaOnboardingCoordinator = nil
					completion()
				}

				self.deltaOnboardingCoordinator?.startOnboarding()
			}
		}.store(in: &subscriptions)
	}

	private func showInformationHowRiskDetectionWorksIfNeeded(completion: @escaping () -> Void = {}) {
		#if DEBUG
		if isUITesting, let showInfo = UserDefaults.standard.string(forKey: "userNeedsToBeInformedAboutHowRiskDetectionWorks") {
			viewModel.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = (showInfo == "YES")
		}
		#endif

		guard viewModel.store.userNeedsToBeInformedAboutHowRiskDetectionWorks else {
			completion()
			return
		}

		let title = AppStrings.Home.riskDetectionHowToAlertTitle
		let message = String(
			format: AppStrings.Home.riskDetectionHowToAlertMessage,
			14
		)

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: NSLocalizedString("Alert_ActionOk", comment: ""),
				style: .default,
				handler: { _ in
					completion()
				}
			)
		)

		present(alert, animated: true) { [weak self] in
			self?.viewModel.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = false
		}
	}

	/// This method checks whether the below conditions in regards to background fetching have been met
	/// and shows the corresponding alert.
	private func showBackgroundFetchAlertIfNeeded(completion: @escaping () -> Void = {}) {
		let status = UIApplication.shared.backgroundRefreshStatus
		let inLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
		let hasSeenAlertBefore = viewModel.store.hasSeenBackgroundFetchAlert

		/// The error alert should only be shown:
		/// - once
		/// - if the background refresh is disabled
		/// - if the user is __not__ in power saving mode, because in this case the background
		///   refresh is disabled automatically. Therefore we have to explicitly check this.
		if status == .available || inLowPowerMode || hasSeenAlertBefore {
			completion()
			return
		}

		let alert = setupErrorAlert(
			title: AppStrings.Common.backgroundFetch_AlertTitle,
			message: AppStrings.Common.backgroundFetch_AlertMessage,
			okTitle: AppStrings.Common.backgroundFetch_OKTitle,
			secondaryActionTitle: AppStrings.Common.backgroundFetch_SettingsTitle,
			secondaryActionCompletion: {
				if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				}
			}
		)

		self.present(
			alert,
			animated: true,
			completion: { [weak self] in
				self?.viewModel.store.hasSeenBackgroundFetchAlert = true
				completion()
			}
		)
	}

	private func showRiskStatusLoweredAlertIfNeeded(completion: @escaping () -> Void = {}) {
		guard viewModel.store.shouldShowRiskStatusLoweredAlert else {
			completion()
			return
		}

		let alert = UIAlertController(
			title: AppStrings.Home.riskStatusLoweredAlertTitle,
			message: AppStrings.Home.riskStatusLoweredAlertMessage,
			preferredStyle: .alert
		)

		let alertAction = UIAlertAction(
			title: AppStrings.Home.riskStatusLoweredAlertPrimaryButtonTitle,
			style: .default,
			handler: { _ in
				completion()
			}
		)
		alert.addAction(alertAction)

		present(alert, animated: true) { [weak self] in
			self?.viewModel.store.shouldShowRiskStatusLoweredAlert = false
		}
	}

	@objc
	private func refreshUIAfterResumingFromBackground() {
		refreshUI()
		showDeltaOnboardingAndAlertsIfNeeded()
	}
	
	@objc
	private func refreshUI() {
		DispatchQueue.main.async { [weak self] in
			self?.viewModel.updateTestResult()
			self?.viewModel.state.updateStatistics()
		}
	}

	// swiftlint:disable:next file_length
}
