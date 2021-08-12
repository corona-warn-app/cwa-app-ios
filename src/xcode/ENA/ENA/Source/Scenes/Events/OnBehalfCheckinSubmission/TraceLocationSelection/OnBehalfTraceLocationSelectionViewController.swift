////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OnBehalfTraceLocationSelectionViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init
	
	init(
		traceLocations: [TraceLocation],
		onScanQRCodeCellTap: @escaping () -> Void,
		onMissingPermissionsButtonTap: @escaping () -> Void,
		onCompletion: @escaping (TraceLocation) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = OnBehalfTraceLocationSelectionViewModel(traceLocations: traceLocations)
		self.onScanQRCodeCellTap = onScanQRCodeCellTap
		self.onMissingPermissionsButtonTap = onMissingPermissionsButtonTap
		self.onCompletion = onCompletion
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

		onCompletion(selectedTraceLocation)
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
	private let onCompletion: (TraceLocation) -> Void
	private let onDismiss: () -> Void

	private var addEntryCellModel = OnBehalfScanQRCodeCellModel()
	private var missingPermissionsCellModel = MissingPermissionsCellModel()

	private var subscriptions: Set<AnyCancellable> = []

	private func setUpTableView() {
		tableView.separatorStyle = .none
		tableView.backgroundColor = .enaColor(for: .darkBackground)

		tableView.register(
			ExposureSubmissionCheckinDescriptionTableViewCell.self,
			forCellReuseIdentifier: ExposureSubmissionCheckinDescriptionTableViewCell.reuseIdentifier
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
			ExposureSubmissionCheckinTableViewCell.self,
			forCellReuseIdentifier: ExposureSubmissionCheckinTableViewCell.reuseIdentifier
		)
	}

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExposureSubmissionCheckinDescriptionTableViewCell.self), for: indexPath) as? ExposureSubmissionCheckinDescriptionTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinDescriptionTableViewCell")
		}

		cell.configure(
			with: ExposureSubmissionCheckinDescriptionCellModel(
				description: AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.description
			)
		)

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
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExposureSubmissionCheckinTableViewCell.self), for: indexPath) as? ExposureSubmissionCheckinTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinTableViewCell")
		}

		cell.configure(with: viewModel.traceLocationCellModels[indexPath.row])

		return cell
	}

	private func setUpEmptyState() {
		let emptyStateView = EmptyStateView(
			viewModel: OnBehalfTraceLocationSelectionEmptyStateViewModel()
		)

		// Since we set the empty state view as a background view we need to push it below the add cell by
		// adding top padding for the height of the add cell …
		emptyStateView.additionalTopPadding = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).maxY
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
