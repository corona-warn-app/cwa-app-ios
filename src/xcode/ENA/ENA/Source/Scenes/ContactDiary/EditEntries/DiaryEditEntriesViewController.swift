////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryEditEntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Init

	init(
		entryType: DiaryEntryType,
		store: DiaryStoringProviding,
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
			.receive(on: RunLoop.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self, self.shouldReload else { return }
				self.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
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
		guard editingStyle == .delete else { return }

		showAlert(
			title: viewModel.deleteOneAlertTitle,
			message: viewModel.deleteOneAlertMessage,
			cancelButtonTitle: viewModel.deleteOneAlertCancelButtonTitle,
			confirmButtonTitle: viewModel.deleteOneAlertConfirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				self.shouldReload = false
				self.viewModel.removeEntry(at: indexPath)
				tableView.performBatchUpdates({
					tableView.deleteRows(at: [indexPath], with: .automatic)
				}, completion: { _ in
					self.shouldReload = true
				})
			}
		)

	}

	// MARK: - Private

	private let viewModel: DiaryEditEntriesViewModel
	private let onCellSelection: (DiaryEntry) -> Void
	private let onDismiss: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var shouldReload = true

	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var deleteAllButton: ENAButton!

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
		
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView
	}

	@IBAction private func didTapDeleteAllButton(_ sender: ENAButton) {
		showAlert(
			title: viewModel.deleteAllAlertTitle,
			message: viewModel.deleteAllAlertMessage,
			cancelButtonTitle: viewModel.deleteAllAlertCancelButtonTitle,
			confirmButtonTitle: viewModel.deleteAllAlertConfirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				let numberOfRows = self.viewModel.entries.count

				self.shouldReload = false
				self.viewModel.removeAll()
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(
						at: (0..<numberOfRows).map { IndexPath(row: $0, section: 0) },
						with: .automatic
					)
				}, completion: { _ in
					self.shouldReload = true
				})
			}
		)
	}

	private func showAlert(
		title: String,
		message: String,
		cancelButtonTitle: String,
		confirmButtonTitle: String,
		confirmAction: @escaping () -> Void
	) {
		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: cancelButtonTitle,
				style: .cancel
			)
		)

		alert.addAction(
			UIAlertAction(
				title: confirmButtonTitle,
				style: .destructive,
				handler: { _ in
					confirmAction()
				}
			)
		)

		present(alert, animated: true, completion: nil)
	}

}
