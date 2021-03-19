//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationTypeSelectionViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: TraceLocationTypeSelectionViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = AppStrings.TraceLocations.TypeSelection.title
		navigationItem.rightBarButtonItem = CloseBarButtonItem { [weak self] in
			self?.onDismiss()
		}
		setupTableView()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(cellType: SelectTraceLocationTypeCell.self, for: indexPath)
		cell.configure(cellModel: viewModel.cellViewModel(at: indexPath))
		return cell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return viewModel.sectionTitle(for: section)
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.selectTraceLocationType(at: indexPath)
	}

	// MARK: - Private

	private let viewModel: TraceLocationTypeSelectionViewModel
	private let onDismiss: () -> Void

	private func setupTableView() {
		tableView.estimatedRowHeight = 60.0
		tableView.rowHeight = UITableView.automaticDimension
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 23, bottom: 0, right: 17)

		tableView.register(SelectTraceLocationTypeCell.self, forCellReuseIdentifier: SelectTraceLocationTypeCell.reuseIdentifier)
	}

}
