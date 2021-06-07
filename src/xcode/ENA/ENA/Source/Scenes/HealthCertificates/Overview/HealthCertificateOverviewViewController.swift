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
		onTestCertificateTap: @escaping (HealthCertificate) -> Void
	) {
		self.viewModel = viewModel
		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onCreateHealthCertificateTap = onCreateHealthCertificateTap
		self.onCertifiedPersonTap = onCertifiedPersonTap
		self.onTestCertificateTap = onTestCertificateTap

		super.init(style: .grouped)
		
		viewModel.$healthCertifiedPersons
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)

		viewModel.$testCertificates
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)

		viewModel.$testCertificateRequests
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)

		viewModel.$testCertificateRequestError
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

		title = AppStrings.HealthCertificate.Overview.title
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
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
		case .description:
			return descriptionCell(forRowAt: indexPath)
		case .healthCertificate:
			return healthCertifiedPersonCell(forRowAt: indexPath)
		case .createHealthCertificate:
			return vaccinationRegistrationCell(forRowAt: indexPath)
		case .testCertificates:
			return testCertificateCell(forRowAt: indexPath)
		case .testCertificateRequests:
			return testCertificateRequestCell(forRowAt: indexPath)
		case .testCertificateInfo:
			return testCertificateInfoCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch HealthCertificateOverviewViewModel.Section(rawValue: indexPath.section) {
		case .description:
			break
		case .createHealthCertificate:
			onCreateHealthCertificateTap()
		case .healthCertificate:
			onCertifiedPersonTap(viewModel.healthCertifiedPersons[indexPath.row])
		case .testCertificates:
			onTestCertificateTap(viewModel.testCertificates[indexPath.row])
		case .testCertificateRequests:
			break
		case .testCertificateInfo:
			break
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: HealthCertificateOverviewViewModel

	private let onInfoBarButtonItemTap: () -> Void
	private let onCreateHealthCertificateTap: () -> Void
	private let onCertifiedPersonTap: (HealthCertifiedPerson) -> Void
	private let onTestCertificateTap: (HealthCertificate) -> Void

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
			UINib(nibName: String(describing: HealthCertificateOverviewDescriptionTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: HealthCertificateOverviewDescriptionTableViewCell.reuseIdentifier
		)
		tableView.register(
			UINib(nibName: String(describing: HomeHealthCertifiedPersonTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: HomeHealthCertifiedPersonTableViewCell.reuseIdentifier
		)
		tableView.register(
			UINib(nibName: String(describing: HomeHealthCertificateRegistrationTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: HomeHealthCertificateRegistrationTableViewCell.reuseIdentifier
		)
		tableView.register(
			UINib(nibName: String(describing: TestCertificateRequestTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: TestCertificateRequestTableViewCell.reuseIdentifier
		)
		tableView.register(
			UINib(nibName: String(describing: TestCertificateInfoTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: TestCertificateInfoTableViewCell.reuseIdentifier
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension

		tableView.sectionHeaderHeight = 0
		tableView.sectionFooterHeight = 0

		// Overestimate to fix auto layout warnings and fix a problem that showed the test cell behind other cells when opening app from the background in manual mode
		tableView.estimatedRowHeight = 500
	}
	
	private func healthCertifiedPersonCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHealthCertifiedPersonTableViewCell.reuseIdentifier, for: indexPath) as? HomeHealthCertifiedPersonTableViewCell else {
			fatalError("Could not dequeue HomeHealthCertifiedPersonTableViewCell")
		}

		let healthCertifiedPerson = viewModel.healthCertifiedPersons[indexPath.row]
		let cellModel = HomeHealthCertifiedPersonCellModel(
			healthCertifiedPerson: healthCertifiedPerson
		)
		cell.configure(with: cellModel)

		return cell
	}

	private func vaccinationRegistrationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHealthCertificateRegistrationTableViewCell.reuseIdentifier, for: indexPath) as? HomeHealthCertificateRegistrationTableViewCell else {
			fatalError("Could not dequeue HomeHealthCertificateRegistrationTableViewCell")
		}

		cell.configure(
			with: HomeHealthCertificateRegistrationCellModel()
		)

		return cell
	}

	private func testCertificateCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHealthCertifiedPersonTableViewCell.reuseIdentifier, for: indexPath) as? HomeHealthCertifiedPersonTableViewCell else {
			fatalError("Could not dequeue HomeHealthCertifiedPersonTableViewCell")
		}

		let cellModel = HomeHealthCertifiedPersonCellModel(
			testCertificate: viewModel.testCertificates[indexPath.row]
		)
		cell.configure(with: cellModel)

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

	private func testCertificateInfoCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: TestCertificateInfoTableViewCell.reuseIdentifier, for: indexPath) as? TestCertificateInfoTableViewCell else {
			fatalError("Could not dequeue TestCertificateInfoTableViewCell")
		}

		cell.configure(
			with: TestCertificateInfoCellModel()
		)

		return cell
	}

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: HealthCertificateOverviewDescriptionTableViewCell.reuseIdentifier, for: indexPath) as? HealthCertificateOverviewDescriptionTableViewCell else {
			fatalError("Could not dequeue HealthCertificateOverviewDescriptionTableViewCell")
		}

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
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Overview.TestCertificateRequest.ErrorAlert.title,
			message: error.localizedDescription,
			preferredStyle: .alert
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
				}
			)
		)

		present(alert, animated: true)
	}

}
