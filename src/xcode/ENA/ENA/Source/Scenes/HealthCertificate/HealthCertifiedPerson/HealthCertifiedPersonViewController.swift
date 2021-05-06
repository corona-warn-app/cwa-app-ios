////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPersonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateServiceProviding,
		healthCertifiedPerson: HealthCertifiedPerson,
		dismiss: @escaping () -> Void,
		didTapHealthCertificate: @escaping (HealthCertificate) -> Void,
		didTapRegisterAnotherHealthCertificate: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.didTapHealthCertificate = didTapHealthCertificate
		self.didTapRegisterAnotherHealthCertificate = didTapRegisterAnotherHealthCertificate
		self.viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson
		)
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBackground()
		setupNavigationBar()
		setupTableView()
		setupViewModel()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		didCalculateGradientHeight = false
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}
		didTapRegisterAnotherHealthCertificate()
	}

	// MARK: - Protocol UITableViewDateSource

	func numberOfSections(in tableView: UITableView) -> Int {
		HealthCertifiedPersonViewModel.TableViewSection.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfItems(in: HealthCertifiedPersonViewModel.TableViewSection.map(section))
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = HealthCertifiedPersonViewModel.TableViewSection.map(indexPath.section)

		switch section {
		case .header:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateSimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.headerCellViewModel)
			return cell

		case .incompleteVaccination:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateSimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.incompleteVaccinationCellViewModel)
			return cell

		case .qrCode:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateQRCodeCell.self, for: indexPath)
			cell.configure(with: viewModel.qrCodeCellViewModel)
			return cell

		case .person:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateSimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.personCellViewModel)
			return cell

		case .certificates:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateCell.self, for: indexPath)
			cell.configure(viewModel.healthCertificateCellViewModel)
			return cell
		}
	}

	// MARK: - Protocol UITableViewDelegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = HealthCertifiedPersonViewModel.TableViewSection.map(indexPath.section)
		switch section {
		case .certificates:
			if let healthCertificate = viewModel.healthCertificate(for: indexPath) {
				didTapHealthCertificate(healthCertificate)
			}
		default:
			break
		}
	}

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapHealthCertificate: (HealthCertificate) -> Void
	private let didTapRegisterAnotherHealthCertificate: () -> Void

	private let viewModel: HealthCertifiedPersonViewModel
	private let backgroundView = GradientBackgroundView(type: .solidGrey)
	private let tableView = UITableView(frame: .zero, style: .plain)

	private var subscriptions = Set<AnyCancellable>()
	private var didCalculateGradientHeight: Bool = false
	private var tableContentObserver: NSKeyValueObservation!

	private func setupNavigationBar() {
		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)

		parent?.navigationController?.navigationBar.tintColor = .white
		parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton(.contrast)
		parent?.navigationItem.hidesBackButton = true

		// create a transparent navigation bar
		let emptyImage = UIImage()
		navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
		navigationController?.navigationBar.shadowImage = emptyImage
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = .clear

		parent?.navigationController?.navigationBar.prefersLargeTitles = false
		parent?.navigationController?.navigationBar.sizeToFit()
		parent?.navigationItem.largeTitleDisplayMode = .never
	}

	private func setupBackground() {
		backgroundView.gradientHeightConstraint.constant = 300.0
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundView)

		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .clear

		view.addSubview(tableView)
		NSLayoutConstraint.activate(
			[
				backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
				backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

				tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

			]
		)

		// observer tableView scrolling to move the background in sync
		// y offset value is required
		tableContentObserver = tableView.observe(\UITableView.contentOffset, options: .new) { [weak self] _, change in
			guard let self = self,
				  let yOffset = change.newValue?.y else {
				return
			}
			let offsetLimit = self.view.safeAreaInsets.top
			self.backgroundView.updatedTopLayout(with: yOffset, limit: offsetLimit)
		}
	}

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		tableView.register(
			HealthCertificateSimpleTextCell.self,
			forCellReuseIdentifier: HealthCertificateSimpleTextCell.reuseIdentifier
		)
		tableView.register(
			HealthCertificateQRCodeCell.self,
			forCellReuseIdentifier: HealthCertificateQRCodeCell.reuseIdentifier
		)
		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: HealthCertificateCell.reuseIdentifier
		)
	}

	private func setupViewModel() {
		viewModel.$gradientType
			.assign(to: \.type, on: backgroundView)
			.store(in: &subscriptions)
	}

}
