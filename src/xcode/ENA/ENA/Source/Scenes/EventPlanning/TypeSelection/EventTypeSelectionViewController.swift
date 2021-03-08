//
// 🦠 Corona-Warn-App
//

import UIKit

class EventTypeSelectionViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: EventTypeSelectionViewModel,
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

		navigationItem.title = AppStrings.EventPlanning.TypeSelection.title

		navigationItem.rightBarButtonItem = CloseBarButtonItem { [weak self] in
			self?.onDismiss()
		}

		navigationController?.navigationBar.prefersLargeTitles = true
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SubtitleCell")

		cell.textLabel?.text = viewModel.title(at: indexPath)
		cell.detailTextLabel?.text = viewModel.description(at: indexPath)

		return cell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return viewModel.sectionTitle(for: section)
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.selectEventType(at: indexPath)
	}

	// MARK: - Private

	private let viewModel: EventTypeSelectionViewModel

	private let onDismiss: () -> Void

}
