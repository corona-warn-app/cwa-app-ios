//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class RecycleBinViewController: UITableViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: RecycleBinViewModel
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
		navigationItem.title = AppStrings.TraceLocations.Overview.title
		navigationItem.rightBarButtonItem = editButtonItem

		viewModel.$recycleBinItems
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self, self.shouldReload else { return }

				self.tableView.reloadData()
				self.updateEmptyState()
			}
			.store(in: &subscriptions)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		parent?.navigationController?.navigationBar.prefersLargeTitles = true
		parent?.navigationController?.navigationBar.sizeToFit()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

//		if !editModeEnteredBySwipeAction {
			footerView?.update(to: editing ? .primary : .none)
//		}
//
//		if editing == false {
//			editModeEnteredBySwipeAction = false
//		}
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
		switch RecycleBinViewModel.Section(rawValue: indexPath.section) {
		case .description:
			return descriptionCell(forRowAt: indexPath)
		case .entries:
			return recycleBinItemCell(forRowAt: indexPath)
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
			title: AppStrings.TraceLocations.Overview.DeleteOneAlert.title,
			message: AppStrings.TraceLocations.Overview.DeleteOneAlert.message,
			cancelButtonTitle: AppStrings.TraceLocations.Overview.DeleteOneAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				self.shouldReload = false
				self.viewModel.removeEntry(at: indexPath)
				tableView.performBatchUpdates({
					tableView.deleteRows(at: [indexPath], with: .automatic)
				}, completion: { _ in
					self.shouldReload = true

					if self.viewModel.isEmpty {
						self.setEditing(false, animated: true)
						self.updateEmptyState()
					}
				})
			}
		)
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch RecycleBinViewModel.Section(rawValue: indexPath.section) {
		case .description:
			break
		case .entries:
			viewModel.didTapEntryCell(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		editModeEnteredBySwipeAction = true
	}

	// MARK: - Private

	private let viewModel: RecycleBinViewModel

	private var subscriptions = [AnyCancellable]()
	private var shouldReload = true
	private var editModeEnteredBySwipeAction = false

	private func setupTableView() {
		tableView.register(
			DynamicTypeTableViewCell.self,
			forCellReuseIdentifier: String(describing: DynamicTypeTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: RecycleBinItemTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: RecycleBinItemTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Overview.tableView
	}

	private func animateChanges(of cell: UITableViewCell) {
		DispatchQueue.main.async { [self] in
			guard tableView.visibleCells.contains(cell) else {
				return
			}

			tableView.performBatchUpdates(nil, completion: nil)
		}
	}

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DynamicTypeTableViewCell.self), for: indexPath) as? DynamicTypeTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinDescriptionTableViewCell")
		}

		cell.configure(
			text: AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.description,
			color: .enaColor(for: .textPrimary2)
		)

		let style: ENALabel.Style = .subheadline
		cell.configureDynamicType(
			size: style.fontSize,
			weight: UIFont.Weight(style.fontWeight),
			style: style.textStyle
		)

		cell.configureAccessibility()

		return cell
	}

	private func recycleBinItemCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecycleBinItemTableViewCell.self), for: indexPath) as? RecycleBinItemTableViewCell else {
			fatalError("Could not dequeue RecycleBinItemTableViewCell")
		}

		cell.configure(
			cellModel: RecycleBinItemCellModel(recycleBinItem: viewModel.recycleBinItems[indexPath.row])
		)

		return cell
	}

	private func updateEmptyState() {
		let emptyStateView = EmptyStateView(viewModel: RecycleBinEmptyStateViewModel())

		// Since we set the empty state view as a background view we need to push it below the navigation bar by
		// adding top padding for the height of the navigation bar
		emptyStateView.additionalTopPadding = parent?.navigationController?.navigationBar.frame.height ?? 0
		// … + the height of the status bar
		if #available(iOS 13.0, *) {
			emptyStateView.additionalTopPadding += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		} else {
			emptyStateView.additionalTopPadding += UIApplication.shared.statusBarFrame.height
		}

		tableView.backgroundView = viewModel.isEmpty ? emptyStateView : nil
	}

	private func didTapDeleteAllButton() {
		showAlert(
			title: AppStrings.TraceLocations.Overview.DeleteAllAlert.title,
			message: AppStrings.TraceLocations.Overview.DeleteAllAlert.message,
			cancelButtonTitle: AppStrings.TraceLocations.Overview.DeleteAllAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.TraceLocations.Overview.DeleteAllAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				let numberOfRows = self.viewModel.recycleBinItems.count

				self.shouldReload = false
				self.viewModel.removeAll()
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(
						at: (0..<numberOfRows).map {
							IndexPath(row: $0, section: RecycleBinViewModel.Section.entries.rawValue)
						},
						with: .automatic
					)
				}, completion: { _ in
					self.shouldReload = true

					self.setEditing(false, animated: true)
					self.updateEmptyState()
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
