////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OnBehalfTraceLocationSelectionViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init
	
	init(
		traceLocations: [TraceLocation],
		onCompletion: @escaping (TraceLocation) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = OnBehalfTraceLocationSelectionViewModel(traceLocations: traceLocations)
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
		
		tableView.separatorStyle = .none
		tableView.backgroundColor = .enaColor(for: .darkBackground)
		tableView.register(ExposureSubmissionCheckinTableViewCell.self, forCellReuseIdentifier: ExposureSubmissionCheckinTableViewCell.reuseIdentifier)
		tableView.register(ExposureSubmissionCheckinDescriptionTableViewCell.self, forCellReuseIdentifier: ExposureSubmissionCheckinDescriptionTableViewCell.reuseIdentifier)
		
		viewModel.$continueEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.footerView?.setEnabled($0, button: .primary)
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
		case .traceLocations:
			viewModel.toggleSelection(at: indexPath.row)
			return
		default:
			Log.error("ExposureSubmissionCheckinsViewController: didSelectRowAt in unknown section", log: .ui, error: nil)
		}
	}
	
	// MARK: - Private
	
	private let viewModel: OnBehalfTraceLocationSelectionViewModel
	private let onCompletion: (TraceLocation) -> Void
	private let onDismiss: () -> Void
	private var subscriptions: Set<AnyCancellable> = []

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
	
	private func traceLocationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExposureSubmissionCheckinTableViewCell.self), for: indexPath) as? ExposureSubmissionCheckinTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinTableViewCell")
		}

		cell.configure(with: viewModel.traceLocationCellModels[indexPath.row])

		return cell
	}
		
}
