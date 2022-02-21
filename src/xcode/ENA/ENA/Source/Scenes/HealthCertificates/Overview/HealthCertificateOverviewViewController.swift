////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateOverviewViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: HealthCertificateOverviewViewModel,
		cclService: CCLServable,
		onInfoBarButtonItemTap: @escaping () -> Void,
		onChangeAdmissionScenarioTap: @escaping () -> Void,
		onCertifiedPersonTap: @escaping (HealthCertifiedPerson) -> Void,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.cclService = cclService
		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onChangeAdmissionScenarioTap = onChangeAdmissionScenarioTap
		self.onCertifiedPersonTap = onCertifiedPersonTap
		self.onCovPassCheckInfoButtonTap = onCovPassCheckInfoButtonTap

		super.init(style: .grouped)
		
		viewModel.$healthCertifiedPersons
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadData()
				self?.updateEmptyState()
			}
			.store(in: &subscriptions)

		viewModel.$testCertificateRequests
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadData()
				self?.updateEmptyState()
			}
			.store(in: &subscriptions)

		viewModel.$testCertificateRequestError
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] in
				guard let self = self, let error = $0 else {
					return
				}

				self.viewModel.testCertificateRequestError = nil
				self.showErrorAlert(error: error)
			}
			.store(in: &subscriptions)
		
		viewModel.$changeAdmissionScenarioStatusText
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadData()
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
		navigationItem.setHidesBackButton(true, animated: false)
		tableView.backgroundColor = .enaColor(for: .darkBackground)
		
		tableView.reloadData()
		title = AppStrings.HealthCertificate.Overview.title
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()

		tableView.reloadData()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		updateEmptyState()
		viewModel.attemptToRestoreDecodingFailedHealthCertificates()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch HealthCertificateOverviewViewModel.Section(rawValue: indexPath.section) {
		case .changeAdmissionScenarioStatusLabel:
			return changeAdmissionScenarioStatusLabelCell(forRowAt: indexPath)
		case .changeAdmissionScenario:
			return changeAdmissionScenarioCell(forRowAt: indexPath)
		case .testCertificateRequest:
			return testCertificateRequestCell(forRowAt: indexPath)
		case .healthCertificate:
			return healthCertifiedPersonCell(forRowAt: indexPath)
		case .healthCertificateScanningInfo:
			return healthCertificateScanningInfoCell(forRowAt: indexPath)
		case .decodingFailedHealthCertificates:
			return decodingFailedHealthCertificateCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch HealthCertificateOverviewViewModel.Section(rawValue: indexPath.section) {
		case .changeAdmissionScenarioStatusLabel:
			break
		case .changeAdmissionScenario:
			onChangeAdmissionScenarioTap()
		case .testCertificateRequest:
			break
		case .healthCertificate:
			onCertifiedPersonTap(viewModel.healthCertifiedPersons[indexPath.row])
		case .healthCertificateScanningInfo:
			break
		case .decodingFailedHealthCertificates:
			break
		case .none:
			fatalError("Invalid section")
		}
	}
	
	// MARK: - Private

	private let viewModel: HealthCertificateOverviewViewModel
	private let cclService: CCLServable
	
	private let onInfoBarButtonItemTap: () -> Void
	private let onChangeAdmissionScenarioTap: () -> Void
	private let onCertifiedPersonTap: (HealthCertifiedPerson) -> Void
	private let onCovPassCheckInfoButtonTap: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	private func setupBarButtonItems() {
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
	}

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddButtonAsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: AddButtonAsTableViewCell.reuseIdentifier
		)

		tableView.register(
			UINib(nibName: String(describing: TestCertificateRequestTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: TestCertificateRequestTableViewCell.reuseIdentifier
		)

		tableView.register(OverviewLabelTableViewCell.self, forCellReuseIdentifier: OverviewLabelTableViewCell.reuseIdentifier)
		tableView.register(HealthCertifiedPersonTableViewCell.self, forCellReuseIdentifier: HealthCertifiedPersonTableViewCell.reuseIdentifier)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension

		tableView.sectionHeaderHeight = 0
		tableView.sectionFooterHeight = 0

		// Overestimate to fix auto layout warnings and fix a problem that showed the test cell behind other cells when opening app from the background in manual mode
		tableView.estimatedRowHeight = 500
	}
	
	private func changeAdmissionScenarioStatusLabelCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OverviewLabelTableViewCell.self), for: indexPath) as? OverviewLabelTableViewCell else {
			fatalError("Could not dequeue OverviewLabelTableCell")
		}

		cell.configure(text: viewModel.changeAdmissionScenarioStatusText?.localized(cclService: cclService) ?? AppStrings.HealthCertificate.Overview.admissionScenarioStatusLabel, noBottomInset: true, textAlignment: .left)
		return cell
	}
	
	private func changeAdmissionScenarioCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddButtonAsTableViewCell.self), for: indexPath) as? AddButtonAsTableViewCell else {
			fatalError("Could not dequeue ChangeAdmissionScenarionCell")
		}

		cell.configure(cellModel: ChangeAdmissionScenarionCellModel(changeAdmissionScenarioButtonText: viewModel.changeAdmissionScenarioButtonText?.localized(cclService: cclService) ?? AppStrings.HealthCertificate.Overview.admissionScenarioButtonLabel))
		cell.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell
		return cell
	}
	
	private func healthCertificateScanningInfoCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OverviewLabelTableViewCell.self), for: indexPath) as? OverviewLabelTableViewCell else {
			fatalError("Could not dequeue OverviewLabelTableCell")
		}

		cell.configure(text: AppStrings.HealthCertificate.Overview.scanningInfo, textAlignment: .center)
		return cell
	}
	
	private func testCertificateRequestCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: TestCertificateRequestTableViewCell.reuseIdentifier, for: indexPath) as? TestCertificateRequestTableViewCell else {
			fatalError("Could not dequeue TestCertificateRequestTableViewCell")
		}

		cell.configure(
			with: TestCertificateRequestCellModel(
				testCertificateRequest: viewModel.testCertificateRequests[indexPath.row]
			),
			onTryAgainButtonTap: { [weak self] in
				self?.viewModel.retryTestCertificateRequest(at: indexPath)
			},
			onRemoveButtonTap: { [weak self] in
				guard let self = self else { return }

				self.showDeleteAlert(testCertificateRequest: self.viewModel.testCertificateRequests[indexPath.row])
			},
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)

		return cell
	}
	
	private func healthCertifiedPersonCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: HealthCertifiedPersonTableViewCell.reuseIdentifier, for: indexPath) as? HealthCertifiedPersonTableViewCell else {
			fatalError("Could not dequeue HealthCertifiedPersonTableViewCell")
		}

		guard let healthCertifiedPerson = viewModel.healthCertifiedPersons[safe: indexPath.row],
			  let cellModel = HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { [weak self] in
					self?.onCovPassCheckInfoButtonTap()
				}
			  ) else {
			return UITableViewCell()
		}

		cell.configure(with: cellModel)

		return cell
	}

	private func decodingFailedHealthCertificateCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: HealthCertifiedPersonTableViewCell.reuseIdentifier, for: indexPath) as? HealthCertifiedPersonTableViewCell else {
			fatalError("Could not dequeue HealthCertifiedPersonTableViewCell")
		}

		guard let decodingFailedHealthCertificate = viewModel.decodingFailedHealthCertificates[safe: indexPath.row],
			  let cellModel = HealthCertifiedPersonCellModel(
				decodingFailedHealthCertificate: decodingFailedHealthCertificate,
				onCovPassCheckInfoButtonTap: { [weak self] in
					self?.onCovPassCheckInfoButtonTap()
				}
			  ) else {
			return UITableViewCell()
		}

		cell.configure(with: cellModel)

		return cell
	}

	@IBAction private func infoButtonTapped() {
		onInfoBarButtonItemTap()
	}

	private func animateChanges(of cell: UITableViewCell) {
		// DispatchQueue prevents undefined behaviour in `visibleCells` while cells are being updated
		// https://developer.apple.com/forums/thread/117537
		DispatchQueue.main.async { [self] in
			guard tableView.visibleCells.contains(cell) else {
				return
			}

			// Animate the changed cell height
			tableView.performBatchUpdates(nil, completion: nil)

			// Keep the other visible cells maskToBounds off during the animation to avoid flickering shadows due to them being cut off (https://stackoverflow.com/a/59581645)
			for cell in tableView.visibleCells {
				cell.layer.masksToBounds = false
				cell.contentView.layer.masksToBounds = false
			}
		}
	}

	private func showErrorAlert(error: HealthCertificateServiceError.TestCertificateRequestError
	) {
		let errorMessage = error.localizedDescription + AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.faqDescription

		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.ErrorAlert.title,
			message: errorMessage,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.faqButtonTitle,
				style: .default,
				handler: { _ in
					if LinkHelper.open(urlString: AppStrings.Links.testCertificateErrorFAQ) {
						alert.dismiss(animated: true)
					}
				}
			)
		)

		let okayAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.ErrorAlert.buttonTitle,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)

		alert.addAction(okayAction)

		present(alert, animated: true, completion: nil)
	}

	private func showDeleteAlert(
		testCertificateRequest: TestCertificateRequest
	) {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.DeleteAlert.title,
			message: AppStrings.HealthCertificate.Overview.TestCertificateRequest.DeleteAlert.message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.DeleteAlert.cancelButtonTitle,
				style: .cancel,
				handler: nil
			)
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.DeleteAlert.deleteButtonTitle,
				style: .destructive,
				handler: { [weak self] _ in
					self?.viewModel.remove(testCertificateRequest: testCertificateRequest)
					self?.updateEmptyState()
				}
			)
		)

		present(alert, animated: true)
	}
	
	private func updateEmptyState() {
		// Since we set the empty state view as a background view we need to push it into the visible area by
		// adding the height of the button cell to the safe area (navigation bar and status bar)
		let safeInsetTop = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).maxY + tableView.adjustedContentInset.top
		// If possible, we want to push it to a position that looks good on large and small screens and that is aligned
		// between CheckinsOverviewViewController, TraceLocationsOverviewViewController and HealthCertificateOverviewViewController.
		let alignmentPadding = UIScreen.main.bounds.height / 3
		tableView.backgroundView = viewModel.isEmpty
			? EmptyStateView(
				viewModel: HealthCertificateOverviewEmptyStateViewModel(),
				safeInsetTop: safeInsetTop,
				safeInsetBottom: tableView.adjustedContentInset.bottom,
				alignmentPadding: alignmentPadding
			)
			: nil
	}
}
