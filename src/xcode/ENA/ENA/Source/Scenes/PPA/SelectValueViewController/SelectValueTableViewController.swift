////
// 🦠 Corona-Warn-App
//

import UIKit

final class SelectValueTableViewController: UITableViewController {

	// MARK: - Init

	init(
		_ viewModel: SelectValueViewModel,
		dissmiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.dissmiss = dissmiss
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

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
		Log.debug("Did changed selection")
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: SelectValueViewModel
	private let dissmiss: () -> Void

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(SelectValueTableViewCell.self, forCellReuseIdentifier: SelectValueTableViewCell.reuseIdentifier)
	}

}
