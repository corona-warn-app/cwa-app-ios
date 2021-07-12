////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateOverviewViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: HealthCertificateOverviewViewModel,
		onInfoBarButtonItemTap: @escaping () -> Void,
		onCreateHealthCertificateTap: @escaping () -> Void,
		onCertifiedPersonTap: @escaping (HealthCertifiedPerson) -> Void,
		onMissingPermissionsButtonTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onCreateHealthCertificateTap = onCreateHealthCertificateTap
		self.onCertifiedPersonTap = onCertifiedPersonTap
		self.onMissingPermissionsButtonTap = onMissingPermissionsButtonTap

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
		
		tableView.reloadData()
		updateEmptyState()

		title = AppStrings.HealthCertificate.Overview.title
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()

		viewModel.resetBadgeCount()
		tableView.reloadData()
		updateEmptyState()
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
		case .createCertificate:
			return addCertificateCell(forRowAt: indexPath)
		case .missingPermission:
			return missingPermissionsCell(forRowAt: indexPath)
		case .testCertificateRequest:
			return testCertificateRequestCell(forRowAt: indexPath)
		case .healthCertificate:
			return healthCertifiedPersonCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch HealthCertificateOverviewViewModel.Section(rawValue: indexPath.section) {
		case .createCertificate:
			onCreateHealthCertificateTap()
		case .missingPermission:
			return
		case .testCertificateRequest:
			break
		case .healthCertificate:
			onCertifiedPersonTap(viewModel.healthCertifiedPersons[indexPath.row])
		case .none:
			fatalError("Invalid section")
		}
	}
	
	// MARK: - Private

	private let viewModel: HealthCertificateOverviewViewModel

	private let onInfoBarButtonItemTap: () -> Void
	private let onCreateHealthCertificateTap: () -> Void
	private let onCertifiedPersonTap: (HealthCertifiedPerson) -> Void
	private let onMissingPermissionsButtonTap: () -> Void
	
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
			MissingPermissionsTableViewCell.self,
			forCellReuseIdentifier: MissingPermissionsTableViewCell.reuseIdentifier
		)
		
		tableView.register(
			UINib(nibName: String(describing: TestCertificateRequestTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: TestCertificateRequestTableViewCell.reuseIdentifier
		)

		tableView.register(HealthCertifiedPersonTableViewCell.self, forCellReuseIdentifier: HealthCertifiedPersonTableViewCell.reuseIdentifier)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension

		tableView.sectionHeaderHeight = 0
		tableView.sectionFooterHeight = 0

		// Overestimate to fix auto layout warnings and fix a problem that showed the test cell behind other cells when opening app from the background in manual mode
		tableView.estimatedRowHeight = 500
	}
	
	private func addCertificateCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddButtonAsTableViewCell.self), for: indexPath) as? AddButtonAsTableViewCell else {
			fatalError("Could not dequeue CreateCertificateTableViewCell")
		}

		cell.configure(cellModel: AddCertificateCellModel())
		cell.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.addCertificateCell
		return cell
	}
	
	private func missingPermissionsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: MissingPermissionsTableViewCell.reuseIdentifier, for: indexPath) as? MissingPermissionsTableViewCell else {
			fatalError("Could not dequeue MissingPermissionsTableViewCell")
		}

		cell.configure(
			cellModel: MissingPermissionsCellModel(),
			onButtonTap: { [weak self] in
				self?.onMissingPermissionsButtonTap()
			}
		)

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
			fatalError("Could not dequeue HomeHealthCertifiedPersonTableViewCell")
		}

		guard let healthCertifiedPerson = viewModel.healthCertifiedPersons[safe: indexPath.row],
			  let cellModel = HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
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
		let emptyStateView = EmptyStateView(viewModel: HealthCertificateOverviewEmptyStateViewModel())

		// Since we set the empty state view as a background view we need to push it below the add cell by
		// adding top padding for the height of the add cell …
		emptyStateView.additionalTopPadding = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).height
		// … + the height of the navigation bar
		emptyStateView.additionalTopPadding += self.navigationController?.navigationBar.frame.height ?? 0
		// … + the height of the status bar
		if #available(iOS 13.0, *) {
			emptyStateView.additionalTopPadding += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		} else {
			emptyStateView.additionalTopPadding += UIApplication.shared.statusBarFrame.height
		}
		tableView.backgroundView = viewModel.isEmptyStateVisible ? emptyStateView : nil
	}
}
