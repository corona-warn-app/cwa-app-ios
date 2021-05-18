////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider,
		dismiss: @escaping () -> Void,
		didTapDelete: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.didTapDelete = didTapDelete
		self.viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
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
		didTapDelete()
	}

	// MARK: - Protocol UITableViewDateSource

	func numberOfSections(in tableView: UITableView) -> Int {
		HealthCertificateViewModel.TableViewSection.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = HealthCertificateViewModel.TableViewSection.map(section) else {
			return 0
		}
		return viewModel.numberOfItems(in: section)
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch HealthCertificateViewModel.TableViewSection.map(indexPath.section) {
		case .headline:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateSimpleTextCell.self, for: indexPath)
			cell.configure(with: viewModel.headlineCellViewModel)
			return cell
		case .qrCode:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateQRCodeCell.self, for: indexPath)
			cell.configure(with: viewModel.qrCodeCellViewModel)
			return cell
		case .topCorner:
			return tableView.dequeueReusableCell(cellType: HealthCertificateTopCornerCell.self, for: indexPath)
		case .details:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateKeyValueTextCell.self, for: indexPath)
			cell.configure(with: viewModel.healthCertificateKeyValueCellViewModel[indexPath.row])
			return cell
		case .bottomCorner:
			return tableView.dequeueReusableCell(cellType: HealthCertificateBottomCornerCell.self, for: indexPath)
		case .none:
			fatalError("can't dequeue a cell for an unknown section")
		}
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// we are only interested in detail cell with person name once if the traitCollectionDidChange - to update gradientHeightConstraint
		guard didCalculateGradientHeight == false,
			  HealthCertificateViewModel.TableViewSection.map(indexPath.section)  == .qrCode,
			  indexPath.row == 0
		else {
			return
		}

		let cellRect = tableView.rectForRow(at: indexPath)
		let result = view.convert(cellRect, from: tableView)
		backgroundView.gradientHeightConstraint.constant = result.midY
		didCalculateGradientHeight = true
	}

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapDelete: () -> Void

	private let viewModel: HealthCertificateViewModel
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
		parent?.navigationItem.titleView = logoImageView
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton(.contrast)

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
			HealthCertificateKeyValueTextCell.self,
			forCellReuseIdentifier: HealthCertificateKeyValueTextCell.reuseIdentifier
		)

		tableView.register(
			HealthCertificateTopCornerCell.self,
			forCellReuseIdentifier: HealthCertificateTopCornerCell.reuseIdentifier
		)

		tableView.register(
			HealthCertificateBottomCornerCell.self,
			forCellReuseIdentifier: HealthCertificateBottomCornerCell.reuseIdentifier
		)
	}

	private func setupViewModel() {
		viewModel.$gradientType
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.type, on: backgroundView)
			.store(in: &subscriptions)

		viewModel.$healthCertificateKeyValueCellViewModel
			.receive(on: DispatchQueue.main.ocombine)
			.sink { _ in
				self.tableView.reloadSections([HealthCertificateViewModel.TableViewSection.details.rawValue], with: .automatic)
			}
			.store(in: &subscriptions)
	}

}
