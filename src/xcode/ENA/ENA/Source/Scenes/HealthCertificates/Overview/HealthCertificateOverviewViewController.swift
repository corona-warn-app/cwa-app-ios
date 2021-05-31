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
		onCertifiedPersonTap: @escaping (HealthCertifiedPerson) -> Void
	) {
		self.viewModel = viewModel
		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onCreateHealthCertificateTap = onCreateHealthCertificateTap
		self.onCertifiedPersonTap = onCertifiedPersonTap

		super.init(style: .grouped)
		
		viewModel.$healthCertifiedPersons
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadSections([
					HealthCertificateOverviewViewModel.Section.healthCertificate.rawValue,
					HealthCertificateOverviewViewModel.Section.createHealthCertificate.rawValue
				], with: .none)
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
			return healthCertificateCell(forRowAt: indexPath)
		case .createHealthCertificate:
			return vaccinationRegistrationCell(forRowAt: indexPath)
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
			if let healthCertifiedPerson = viewModel.healthCertifiedPerson(at: indexPath) {
				onCertifiedPersonTap(healthCertifiedPerson)
			}
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
	
	private func healthCertificateCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
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

}
