////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OnBehalfTraceLocationSelectionViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init
	
	init(
		viewModel: OnBehalfTraceLocationSelectionViewModel,
		onScanQRCodeCellTap: @escaping () -> Void,
		onMissingPermissionsButtonTap: @escaping () -> Void,
		onPrimaryButtonTap: @escaping (TraceLocation) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onScanQRCodeCellTap = onScanQRCodeCellTap
		self.onMissingPermissionsButtonTap = onMissingPermissionsButtonTap
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onDismiss = onDismiss
		
		super.init(style: .plain)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()

		parent?.title = viewModel.title
		parent?.navigationItem.largeTitleDisplayMode = .always
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton

		setUpTableView()

		tableView.reloadData()
		setUpEmptyState()
		
		viewModel.$continueEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.footerView?.setEnabled($0, button: .primary)
			}
			.store(in: &subscriptions)

		viewModel.$triggerReload
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self else { return }

				self.tableView.reloadData()
				self.setUpEmptyState()
			}
			.store(in: &subscriptions)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		onDismiss()
	}
		
	// MARK: - Protocol FooterViewHandling
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary, let selectedTraceLocation = viewModel.selectedTraceLocation else {
			return
		}

		onPrimaryButtonTap(selectedTraceLocation)
	}
	
	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch OnBehalfTraceLocationSelectionViewModel.Section(rawValue: indexPath.section) {
		case .description:
			return descriptionCell(forRowAt: indexPath)
		case .qrCodeScan:
			return scanTraceLocationCell(forRowAt: indexPath)
		case .missingCameraPermission:
			return missingPermissionsCell(forRowAt: indexPath)
		case .traceLocations:
			return traceLocationCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch OnBehalfTraceLocationSelectionViewModel.Section(rawValue: indexPath.section) {
		case .description:
			return
		case .qrCodeScan:
			onScanQRCodeCellTap()
		case .missingCameraPermission:
			return
		case .traceLocations:
			viewModel.toggleSelection(at: indexPath.row)
			return
		default:
			Log.error("ExposureSubmissionCheckinsViewController: didSelectRowAt in unknown section", log: .ui, error: nil)
		}
	}
	
	// MARK: - Private
	
	private let viewModel: OnBehalfTraceLocationSelectionViewModel
	private let onScanQRCodeCellTap: () -> Void
	private let onMissingPermissionsButtonTap: () -> Void
	private let onPrimaryButtonTap: (TraceLocation) -> Void
	private let onDismiss: () -> Void

	private var addEntryCellModel = OnBehalfScanQRCodeCellModel()
	private var missingPermissionsCellModel = MissingPermissionsCellModel()

	private var subscriptions: Set<AnyCancellable> = []

	private func setUpTableView() {
		tableView.separatorStyle = .none
		tableView.backgroundColor = .enaColor(for: .background)

		tableView.register(
			DynamicTypeTableViewCell.self,
			forCellReuseIdentifier: String(describing: DynamicTypeTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: AddButtonAsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddButtonAsTableViewCell.self)
		)

		tableView.register(
			MissingPermissionsTableViewCell.self,
			forCellReuseIdentifier: MissingPermissionsTableViewCell.reuseIdentifier
		)

		tableView.register(
			TraceLocationCheckinSelectionTableViewCell.self,
			forCellReuseIdentifier: TraceLocationCheckinSelectionTableViewCell.reuseIdentifier
		)
	}

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DynamicTypeTableViewCell.self), for: indexPath) as? DynamicTypeTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinDescriptionTableViewCell")
		}

		cell.configure(
			text: AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.description,
			color: .enaColor(for: .textPrimary2)
		)

		let style: ENALabel.Style = .subheadline
		cell.configureDynamicType(
			size: style.fontSize,
			weight: UIFont.Weight(style.fontWeight),
			style: style.textStyle
		)

		cell.configureAccessibility()

		return cell
	}

	private func scanTraceLocationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddButtonAsTableViewCell.self), for: indexPath) as? AddButtonAsTableViewCell else {
			fatalError("Could not dequeue AddButtonAsTableViewCell")
		}

		cell.configure(cellModel: addEntryCellModel)

		return cell
	}

	private func missingPermissionsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: MissingPermissionsTableViewCell.reuseIdentifier, for: indexPath) as? MissingPermissionsTableViewCell else {
			fatalError("Could not dequeue MissingPermissionsTableViewCell")
		}

		cell.configure(
			cellModel: missingPermissionsCellModel,
			onButtonTap: { [weak self] in
				self?.onMissingPermissionsButtonTap()
			}
		)

		return cell
	}
	
	private func traceLocationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TraceLocationCheckinSelectionTableViewCell.self), for: indexPath) as? TraceLocationCheckinSelectionTableViewCell else {
			fatalError("Could not dequeue TraceLocationCheckinSelectionTableViewCell")
		}

		cell.configure(with: viewModel.traceLocationCellModels[indexPath.row])

		return cell
	}

	private func setUpEmptyState() {
		let emptyStateView = EmptyStateView(
			viewModel: OnBehalfTraceLocationSelectionEmptyStateViewModel()
		)

		// Since we set the empty state view as a background view we need to push it below the add cell by
		// adding top padding for the description and scan QR code or camera permission cell
		let visibleScanOrCameraPermissionSection = viewModel.numberOfRows(in: 1) == 1 ? 1 : 2
		emptyStateView.additionalTopPadding = tableView.rectForRow(at: IndexPath(row: 0, section: visibleScanOrCameraPermissionSection)).maxY
		// … + the height of the navigation bar
		emptyStateView.additionalTopPadding += parent?.navigationController?.navigationBar.frame.height ?? 0
		// … + the height of the status bar
		if #available(iOS 13.0, *) {
			emptyStateView.additionalTopPadding += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		} else {
			emptyStateView.additionalTopPadding += UIApplication.shared.statusBarFrame.height
		}

		tableView.backgroundView = viewModel.isEmptyStateVisible ? emptyStateView : nil
	}
		
}
