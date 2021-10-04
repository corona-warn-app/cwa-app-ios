////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionCheckinsViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init
	
	init(checkins: [Checkin], onCompletion: @escaping ([Checkin]) -> Void, onSkip: @escaping () -> Void, onDismiss: @escaping () -> Void) {
		self.viewModel = ExposureSubmissionCheckinsViewModel(checkins: checkins)
		self.onCompletion = onCompletion
		self.onSkip = onSkip
		self.onDismiss = onDismiss
		
		super.init(style: .plain)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = viewModel.title
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		
		tableView.separatorStyle = .none
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.register(TraceLocationCheckinSelectionTableViewCell.self, forCellReuseIdentifier: TraceLocationCheckinSelectionTableViewCell.reuseIdentifier)
		tableView.register(ExposureSubmissionCheckinDescriptionTableViewCell.self, forCellReuseIdentifier: ExposureSubmissionCheckinDescriptionTableViewCell.reuseIdentifier)
		
		viewModel.$continueEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.footerView?.setEnabled($0, button: .primary)
			}
			.store(in: &subscriptions)
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		onDismiss()
	}
		
	// MARK: - Protocol FooterViewHandling
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			// Submit
			onCompletion(viewModel.selectedCheckins)
		case .secondary:
			// Skip
			onSkip()
		}
	}
	
	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch ExposureSubmissionCheckinsViewModel.Section(rawValue: indexPath.section) {
		case .description:
			return descriptionCell(forRowAt: indexPath)
		case .checkins:
			return checkinCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard ExposureSubmissionCheckinsViewModel.Section(rawValue: section) == .checkins else {
			return UIView()
		}
		
		let selectAllButton = UIButton()
		selectAllButton.backgroundColor = .enaColor(for: .background)
		selectAllButton.contentHorizontalAlignment = .left
		selectAllButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		selectAllButton.setTitleColor(.enaColor(for: .textTint), for: .normal)
		selectAllButton.setTitle(AppStrings.ExposureSubmissionCheckins.selectAll, for: .normal)
		selectAllButton.addTarget(viewModel, action: #selector(viewModel.selectAll), for: .touchUpInside)
		return selectAllButton
	}

	// MARK: - Protocol UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch ExposureSubmissionCheckinsViewModel.Section(rawValue: indexPath.section) {
		case .description:
			return
		case .checkins:
			viewModel.toggleSelection(at: indexPath.row)
			return
		default:
			Log.error("ExposureSubmissionCheckinsViewController: didSelectRowAt in unknown section", log: .ui, error: nil)
		}
	}
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionCheckinsViewModel
	private let onCompletion: ([Checkin]) -> Void
	private let onSkip: () -> Void
	private let onDismiss: () -> Void
	private var subscriptions: Set<AnyCancellable> = []

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExposureSubmissionCheckinDescriptionTableViewCell.self), for: indexPath) as? ExposureSubmissionCheckinDescriptionTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinDescriptionTableViewCell")
		}
		return cell
	}
	
	private func checkinCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TraceLocationCheckinSelectionTableViewCell.self), for: indexPath) as? TraceLocationCheckinSelectionTableViewCell else {
			fatalError("Could not dequeue TraceLocationCheckinSelectionTableViewCell")
		}

		cell.configure(with: viewModel.checkinCellModels[indexPath.row])

		return cell
	}
		
}
