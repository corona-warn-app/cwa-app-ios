//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class FamilyMemberCoronaTestsViewController: UITableViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: FamilyMemberCoronaTestsViewModel
	) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .darkBackground)
		footerView?.setBackgroundColor(.enaColor(for: .darkBackground))

		setupTableView()
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.FamilyMemberCoronaTest.title
		navigationItem.rightBarButtonItem = editButtonItem

		tableView.reloadData()

		viewModel.onUpdate = { [weak self] in
			self?.animateChanges()
		}

		viewModel.$triggerReload
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] triggerReload in
				guard let self = self, triggerReload else { return }

				guard self.isAllowedToReload else {
					self.viewModel.triggerReload = false
					return
				}

				self.tableView.reloadData()
				self.viewModel.triggerReload = false
			}
			.store(in: &subscriptions)
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		// Only reset to false because it is also set to true for single-row swipe to delete and we don't want to enter edit mode then.
		if editing == false {
			updateFor(isEditing: false)
		}
	}

	// MARK: - FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		if type == .primary {
			didTapDeleteAllButton()
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
		switch FamilyMemberCoronaTestsViewModel.Section(rawValue: indexPath.section) {
		case .coronaTests:
			return coronaTestCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		viewModel.canEditRow(at: indexPath)
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }

		showAlert(
			title: AppStrings.FamilyMemberCoronaTest.DeleteOneAlert.title,
			message: AppStrings.FamilyMemberCoronaTest.DeleteOneAlert.message,
			cancelButtonTitle: AppStrings.FamilyMemberCoronaTest.DeleteOneAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.FamilyMemberCoronaTest.DeleteOneAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				self.isAllowedToReload = false
				self.viewModel.removeEntry(at: indexPath)
				tableView.performBatchUpdates({
					tableView.deleteRows(at: [indexPath], with: .automatic)
				}, completion: { _ in
					self.isAllowedToReload = true
					self.viewModel.triggerReload = true

					if self.viewModel.isEmpty {
						self.setEditing(false, animated: true)
					}
				})
			}
		)
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch FamilyMemberCoronaTestsViewModel.Section(rawValue: indexPath.section) {
		case .coronaTests:
			viewModel.didTapCoronaTestCell(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: FamilyMemberCoronaTestsViewModel

	private var subscriptions = Set<AnyCancellable>()
	private var isAllowedToReload = true

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: FamilyMemberCoronaTestTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: FamilyMemberCoronaTestTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func animateChanges() {
		guard !viewModel.triggerReload else { return }

		DispatchQueue.main.async { [self] in
			tableView.performBatchUpdates(nil, completion: nil)
			
			// Keep the other visible cells maskToBounds off during the animation to avoid flickering shadows due to them being cut off (https://stackoverflow.com/a/59581645)
			for cell in tableView.visibleCells {
				cell.layer.masksToBounds = false
				cell.contentView.layer.masksToBounds = false
			}
		}
	}

	private func updateFor(isEditing: Bool) {
		let newState: FooterViewModel.VisibleButtons = isEditing ? .primary : .none
		footerView?.update(to: newState)
	}

	private func coronaTestCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FamilyMemberCoronaTestTableViewCell.self), for: indexPath) as? FamilyMemberCoronaTestTableViewCell else {
			fatalError("Could not dequeue FamilyMemberCoronaTestTableViewCell")
		}

		let cellModel = viewModel.coronaTestCellModels[indexPath.row]
		cell.configure(
			with: cellModel,
			onPrimaryAction: { [weak self] in
				guard let self = self,
					  let currentIndexPath = self.tableView.indexPath(for: cell) else {
					return
				}
				self.viewModel.didTapCoronaTestCellButton(at: currentIndexPath)
			}
		)

		return cell
	}

	private func didTapDeleteAllButton() {
		showAlert(
			title: AppStrings.FamilyMemberCoronaTest.DeleteAllAlert.title,
			message: AppStrings.FamilyMemberCoronaTest.DeleteAllAlert.message,
			cancelButtonTitle: AppStrings.FamilyMemberCoronaTest.DeleteAllAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.FamilyMemberCoronaTest.DeleteAllAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				let numberOfRows = self.viewModel.numberOfRows(in: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue)

				self.isAllowedToReload = false
				self.viewModel.removeAll()
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(
						at: (0..<numberOfRows).map {
							IndexPath(row: $0, section: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue)
						},
						with: .automatic
					)
				}, completion: { _ in
					self.isAllowedToReload = true

					self.setEditing(false, animated: true)
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
