////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class DiaryEditEntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Init

	init(
		entryType: DiaryEntryType,
		store: DiaryStoring,
		onCellSelection: @escaping (DiaryEntry) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = DiaryEditEntriesViewModel(entryType: entryType, store: store)
		self.onCellSelection = onCellSelection
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

		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		navigationItem.title = viewModel.title
		deleteAllButton.setTitle(viewModel.deleteAllButtonTitle, for: .normal)

		view.backgroundColor = .enaColor(for: .darkBackground)

		setupTableView()

		viewModel.$entries
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				guard let self = self, self.shouldReload else { return }
				self.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		// Needs to be set to 0 when empty for the animation of deleting the whole section
		return viewModel.entries.isEmpty ? 0 : 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.entries.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryEditEntriesTableViewCell.self), for: indexPath) as? DiaryEditEntriesTableViewCell else {
			fatalError("Could not dequeue DiaryEditEntriesTableViewCell")
		}

		let cellModel = DiaryEditEntriesCellModel(entry: viewModel.entries[indexPath.row])
		cell.configure(model: cellModel)

		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onCellSelection(viewModel.entries[indexPath.row])
	}

	func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		onCellSelection(viewModel.entries[indexPath.row])
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			shouldReload = false
			viewModel.removeEntry(at: indexPath)
			tableView.performBatchUpdates({
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}, completion: { _ in
				self.shouldReload = true
			})
		}
	}

	// MARK: - Private

	private let viewModel: DiaryEditEntriesViewModel
	private let onCellSelection: (DiaryEntry) -> Void
	private let onDismiss: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var shouldReload = true

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var deleteAllButton: ENAButton!

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: DiaryEditEntriesTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryEditEntriesTableViewCell.self)
		)

		tableView.delegate = self
		tableView.dataSource = self

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60

		tableView.isEditing = true
	}

	@IBAction func didTapDeleteAllButton(_ sender: ENAButton) {
		let alert = UIAlertController(
			title: viewModel.alertTitle,
			message: viewModel.alertMessage,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: viewModel.alertCancelButtonTitle,
				style: .cancel
			)
		)

		alert.addAction(
			UIAlertAction(
				title: viewModel.alertConfirmButtonTitle,
				style: .destructive,
				handler: { [weak self] _ in
					self?.shouldReload = false
					self?.viewModel.removeAll()
					self?.tableView.performBatchUpdates({
						self?.tableView.deleteSections([0], with: .automatic)
					}, completion: { _ in
						self?.shouldReload = true
					})
				}
			)
		)

		present(alert, animated: true, completion: nil)
	}

}
