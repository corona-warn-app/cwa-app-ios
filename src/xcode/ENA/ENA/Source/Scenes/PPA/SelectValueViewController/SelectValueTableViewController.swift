////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class SelectValueTableViewController: UITableViewController {

	// MARK: - Init

	init(
		_ viewModel: SelectValueViewModel,
		dissmiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.dissmiss = dissmiss
		self.subscriptions = []
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		setupTableView()
	}

	// MARK: - Protocol UITableViewDataSource

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfSelectableValues
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(cellType: SelectValueTableViewCell.self, for: indexPath)
		cell.configure(viewModel.cellViewModel(for: indexPath))
		return cell
	}

	// MARK: - Protocol UITableViewDataSource

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.selectValue(at: indexPath)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: SelectValueViewModel
	private let dissmiss: () -> Void
	private var subscriptions: [AnyCancellable]

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(SelectValueTableViewCell.self, forCellReuseIdentifier: SelectValueTableViewCell.reuseIdentifier)

		// wire up tabelview to react on viewmodel changes
		viewModel.$selectedIndex
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] rowChange in
				let newSelectionIndexPath = IndexPath(row: rowChange.1, section: 0)
				let oldSelcetionIndexPath: IndexPath?
				if let oldRow = rowChange.0 {
					oldSelcetionIndexPath = IndexPath(row: oldRow, section: 0)
				} else {
					oldSelcetionIndexPath = nil
				}
				guard newSelectionIndexPath != oldSelcetionIndexPath else { return }
				self?.tableView.reloadRows(at: [oldSelcetionIndexPath, newSelectionIndexPath].compactMap({ $0 }), with: .automatic)
			}
			.store(in: &subscriptions)
	}

	private func setupNavigationBar() {
		title = viewModel.title

		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dissmiss)
	}

}
