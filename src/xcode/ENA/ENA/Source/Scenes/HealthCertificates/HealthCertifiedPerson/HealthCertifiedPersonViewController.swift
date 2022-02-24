////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPersonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DismissHandling {

	// MARK: - Init

	init(
		cclService: CCLServable,
		healthCertificateService: HealthCertificateService,
		healthCertifiedPerson: HealthCertifiedPerson,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		dismiss: @escaping () -> Void,
		didTapValidationButton: @escaping (HealthCertificate, @escaping (Bool) -> Void) -> Void,
		didTapBoosterNotification: @escaping (HealthCertifiedPerson) -> Void,
		didTapHealthCertificate: @escaping (HealthCertificate) -> Void,
		didSwipeToDelete: @escaping (HealthCertificate, @escaping () -> Void) -> Void,
		showInfoHit: @escaping () -> Void,
		didTapCertificateReissuance: @escaping (HealthCertifiedPerson) -> Void
	) {
		self.dismiss = dismiss
		self.didTapHealthCertificate = didTapHealthCertificate
		self.didSwipeToDelete = didSwipeToDelete

		self.viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: dismiss,
			didTapBoosterNotification: didTapBoosterNotification,
			didTapValidationButton: didTapValidationButton,
			showInfoHit: showInfoHit,
			didTapCertificateReissuance: didTapCertificateReissuance
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		viewModel.attemptToRestoreDecodingFailedHealthCertificates()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		didCalculateGradientHeight = false
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
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

		case .qrCode:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateQRCodeCell.self, for: indexPath)
			cell.configure(with: viewModel.qrCodeCellViewModel)
			return cell

		case .certificateReissuance:
			let cell = tableView.dequeueReusableCell(cellType: CertificateReissuanceTableViewCell.self, for: indexPath)
			cell.configure(with: viewModel.certificateReissuanceCellModel)
			return cell

		case .boosterNotification:
			let cell = tableView.dequeueReusableCell(cellType: BoosterNotificationTableViewCell.self, for: indexPath)
			cell.configure(with: viewModel.boosterNotificationCellModel)
			return cell

		case .admissionState:
			let cell = tableView.dequeueReusableCell(cellType: AdmissionStateTableViewCell.self, for: indexPath)
			cell.configure(with: viewModel.admissionStateCellModel)
			return cell

		case .vaccinationState:
			let cell = tableView.dequeueReusableCell(cellType: VaccinationStateTableViewCell.self, for: indexPath)
			cell.configure(with: viewModel.vaccinationStateCellModel)
			return cell

		case .person:
			let cell = tableView.dequeueReusableCell(cellType: PreferredPersonTableViewCell.self, for: indexPath)
			cell.configure(with: viewModel.preferredPersonCellModel)
			return cell

		case .certificates:
			let cell = tableView.dequeueReusableCell(cellType: HealthCertificateCell.self, for: indexPath)
			cell.configure(viewModel.healthCertificateCellViewModel(row: indexPath.row))
			return cell
		}
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if HealthCertifiedPersonViewModel.TableViewSection.map(section) == .certificates {
			let footerView = UIView()
			footerView.backgroundColor = .clear

			return footerView
		} else {
			return nil
		}
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let section = HealthCertifiedPersonViewModel.TableViewSection.map(section)
		return viewModel.heightForFooter(in: section)
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// we are only interested in QRCode cell once if the traitCollectionDidChange - to update gradientHeightConstraint
		guard
			didCalculateGradientHeight == false,
			HealthCertifiedPersonViewModel.TableViewSection.map(indexPath.section) == .qrCode
		else {
			return
		}

		let cellRect = tableView.rectForRow(at: indexPath)
		backgroundView.gradientHeightConstraint.constant = cellRect.midY + (tableView.contentOffset.y / 2) + view.safeAreaInsets.top
		didCalculateGradientHeight = true
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = HealthCertifiedPersonViewModel.TableViewSection.map(indexPath.section)
		switch section {
		case .certificateReissuance:
			viewModel.didTapCertificateReissuanceCell()
		case .boosterNotification:
			viewModel.didTapBoosterNotificationCell()
		case .certificates:
			if let healthCertificate = viewModel.healthCertificate(for: indexPath) {
				didTapHealthCertificate(healthCertificate)
			}
		default:
			break
		}
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		viewModel.canEditRow(at: indexPath)
	}

	// swiftlint:disable cyclomatic_complexity
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete, let healthCertificate = viewModel.healthCertificate(for: indexPath) else { return }

		let vaccinationStateWasVisible = viewModel.vaccinationStateIsVisible
		let admissionStateWasVisible = viewModel.admissionStateIsVisible
		let boosterNotificationWasVisible = viewModel.boosterNotificationIsVisible

		let previousCertificates = viewModel.healthCertifiedPerson.healthCertificates.sorted(by: >)

		self.didSwipeToDelete(healthCertificate) { [weak self] in
			guard let self = self else { return }

			self.isAnimatingChanges = true

			tableView.performBatchUpdates({
				var deleteIndexPaths = [indexPath]
				var insertIndexPaths = [IndexPath]()

				if vaccinationStateWasVisible && !self.viewModel.vaccinationStateIsVisible {
					deleteIndexPaths.append(IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.vaccinationState.rawValue))
				} else if !vaccinationStateWasVisible && self.viewModel.vaccinationStateIsVisible {
					insertIndexPaths.append(IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.vaccinationState.rawValue))
				}
				
				if admissionStateWasVisible && !self.viewModel.admissionStateIsVisible {
					deleteIndexPaths.append(IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.admissionState.rawValue))
				} else if !admissionStateWasVisible && self.viewModel.admissionStateIsVisible {
					insertIndexPaths.append(IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.admissionState.rawValue))
				}

				if boosterNotificationWasVisible && !self.viewModel.boosterNotificationIsVisible {
					deleteIndexPaths.append(IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.boosterNotification.rawValue))
				} else if !boosterNotificationWasVisible && self.viewModel.boosterNotificationIsVisible {
					insertIndexPaths.append(IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.boosterNotification.rawValue))
				}

				// For the case that a person splits after deleting a certificate, there could be some more certificates to be removed (because they are moved into a new person).
				for (index, certificate) in previousCertificates.enumerated() where certificate != healthCertificate {
					if !self.viewModel.healthCertifiedPerson.healthCertificates.contains(certificate) {
						deleteIndexPaths.append(IndexPath(row: index, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue))
					}
				}

				tableView.deleteRows(at: deleteIndexPaths, with: .automatic)
				tableView.insertRows(at: insertIndexPaths, with: .automatic)
			}, completion: { _ in
				self.isAnimatingChanges = false

				// Reload is required to update cells with new cell models if most relevant certificate was deleted
				if self.viewModel.numberOfItems(in: .certificates) > 0 {
					self.tableView.reloadData()
				}
			})
		}
	}

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapHealthCertificate: (HealthCertificate) -> Void
	private let didSwipeToDelete: (HealthCertificate, @escaping () -> Void) -> Void

	private let viewModel: HealthCertifiedPersonViewModel
	private let backgroundView = GradientBackgroundView(type: .solidGrey, withStars: true)
	private let tableView = UITableView(frame: .zero, style: .plain)

	private var subscriptions = Set<AnyCancellable>()
	private var didCalculateGradientHeight: Bool = false
	private var tableContentObserver: NSKeyValueObservation!

	private var isAnimatingChanges = false

	private func setupNavigationBar() {
		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App-Small").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)

		navigationController?.navigationBar.tintColor = .white
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton(.contrast)
		navigationItem.hidesBackButton = true

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.setupTransparentNavigationBar()
		}
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
			BoosterNotificationTableViewCell.self,
			forCellReuseIdentifier: BoosterNotificationTableViewCell.reuseIdentifier
		)
		tableView.register(
			AdmissionStateTableViewCell.self,
			forCellReuseIdentifier: AdmissionStateTableViewCell.reuseIdentifier
		)
		tableView.register(
			VaccinationStateTableViewCell.self,
			forCellReuseIdentifier: VaccinationStateTableViewCell.reuseIdentifier
		)
		tableView.register(
			PreferredPersonTableViewCell.self,
			forCellReuseIdentifier: PreferredPersonTableViewCell.reuseIdentifier
		)
		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: HealthCertificateCell.reuseIdentifier
		)
	}

	private func setupViewModel() {
		viewModel.$gradientType
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.type, on: backgroundView)
			.store(in: &subscriptions)

		viewModel.$triggerReload
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] triggerReload in
				guard triggerReload, let self = self, !self.isAnimatingChanges else { return }

				self.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

}
