//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinsOverviewViewController: UITableViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: CheckinsOverviewViewModel,
		onInfoButtonTap: @escaping () -> Void,
		onAddEntryCellTap: @escaping () -> Void,
		onMissingPermissionsButtonTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoButtonTap = onInfoButtonTap
		self.onAddEntryCellTap = onAddEntryCellTap
		self.onMissingPermissionsButtonTap = onMissingPermissionsButtonTap

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
		parent?.navigationItem.largeTitleDisplayMode = .always
		parent?.navigationItem.title = AppStrings.Checkins.Overview.title
		updateRightBarButtonItem(isEditing: false)

		viewModel.onUpdate = { [weak self] in
			self?.animateChanges()
		}

		viewModel.$triggerReload
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self else { return }

				guard self.viewModel.triggerReload, self.isAllowedToReload else {
					self.viewModel.triggerReload = false
					return
				}

				self.tableView.reloadData()
				self.updateEmptyState()
				self.viewModel.triggerReload = false
			}
			.store(in: &subscriptions)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.checkoutOverdueCheckins()
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
		switch CheckinsOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return checkinAddCell(forRowAt: indexPath)
		case .missingPermission:
			return missingPermissionsCell(forRowAt: indexPath)
		case .entries:
			return checkinCell(forRowAt: indexPath)
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
			title: AppStrings.Checkins.Overview.DeleteOneAlert.title,
			message: AppStrings.Checkins.Overview.DeleteOneAlert.message,
			cancelButtonTitle: AppStrings.Checkins.Overview.DeleteOneAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.Checkins.Overview.DeleteOneAlert.confirmButtonTitle,
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
						self.updateEmptyState()
					}
				})
			}
		)
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch CheckinsOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			onAddEntryCellTap()
		case .missingPermission:
			return
		case .entries:
			viewModel.didTapEntryCell(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		didTapDeleteAllButton()
	}

	// MARK: - Private

	private let viewModel: CheckinsOverviewViewModel
	private let onInfoButtonTap: () -> Void
	private let onAddEntryCellTap: () -> Void
	private let onMissingPermissionsButtonTap: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var isAllowedToReload = true
	private var addEntryCellModel = AddCheckinCellModel()
	private var missingPermissionsCellModel = MissingPermissionsCellModel()

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddEventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddEventTableViewCell.self)
		)

		tableView.register(
			MissingPermissionsTableViewCell.self,
			forCellReuseIdentifier: MissingPermissionsTableViewCell.reuseIdentifier
		)

		tableView.register(
			UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: EventTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func animateChanges() {
		guard !viewModel.triggerReload else { return }

		DispatchQueue.main.async { [self] in
			tableView.performBatchUpdates(nil, completion: nil)
		}
	}

	private func updateFor(isEditing: Bool) {
		updateRightBarButtonItem(isEditing: isEditing)
		addEntryCellModel.setEnabled(!isEditing)
		missingPermissionsCellModel.setEnabled(!isEditing)

		let newState: FooterViewModel.VisibleButtons = isEditing ? .primary : .none
		footerView?.update(to: newState)
	}

	private func updateRightBarButtonItem(isEditing: Bool) {
		// Only update if necessary to prevent unnecessary animations
		if isEditing && parent?.navigationItem.rightBarButtonItem != editButtonItem {
			parent?.navigationItem.setRightBarButton(editButtonItem, animated: true)
		} else if parent?.navigationItem.rightBarButtonItem == nil || parent?.navigationItem.rightBarButtonItem == editButtonItem {
			let barButtonItem = UIBarButtonItem(
				image: UIImage(named: "Icons_More_Circle"),
				style: .plain,
				target: self,
				action: #selector(didTapMoreButton)
			)
			barButtonItem.accessibilityLabel = AppStrings.Checkins.Overview.menuButtonTitle
			barButtonItem.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Overview.menueButton
			barButtonItem.tintColor = .enaColor(for: .tint)

			parent?.navigationItem.setRightBarButton(barButtonItem, animated: true)
		}
	}

	private func checkinAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddEventTableViewCell.self), for: indexPath) as? AddEventTableViewCell else {
			fatalError("Could not dequeue AddEventTableViewCell")
		}

		cell.configure(cellModel: addEntryCellModel)

		return cell
	}

	private func missingPermissionsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: MissingPermissionsTableViewCell.reuseIdentifier, for: indexPath) as? MissingPermissionsTableViewCell else {
			fatalError("Could not dequeue MissingPermissionsTableViewCell")
		}

		cell.configure(
			cellModel: missingPermissionsCellModel,
			onButtonTap: { [weak self] in
				self?.onMissingPermissionsButtonTap()
			}
		)

		return cell
	}

	private func checkinCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self), for: indexPath) as? EventTableViewCell else {
			fatalError("Could not dequeue EventTableViewCell")
		}

		let cellModel = viewModel.checkinCellModels[indexPath.row]
		cell.configure(
			cellModel: cellModel,
			onButtonTap: { [weak self] in
				self?.viewModel.didTapEntryCellButton(at: indexPath)
			}
		)

		return cell
	}

	private func updateEmptyState() {
		let emptyStateView = EmptyStateView(viewModel: CheckinsOverviewEmptyStateViewModel())

		// Since we set the empty state view as a background view we need to push it below the add cell by
		// adding top padding for the height of the add cell …
		emptyStateView.additionalTopPadding = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).maxY
		// … + the height of the navigation bar
		emptyStateView.additionalTopPadding += parent?.navigationController?.navigationBar.frame.height ?? 0
		// … + the height of the status bar
		if #available(iOS 13.0, *) {
			emptyStateView.additionalTopPadding += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		} else {
			emptyStateView.additionalTopPadding += UIApplication.shared.statusBarFrame.height
		}

		tableView.backgroundView = viewModel.isEmptyStateVisible ? emptyStateView : nil
	}

	@objc
	private func didTapMoreButton() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let infoAction = UIAlertAction(
			title: AppStrings.Checkins.Overview.ActionSheet.infoTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.onInfoButtonTap()
			}
		)
		actionSheet.addAction(infoAction)

		let editAction = UIAlertAction(
			title: AppStrings.Checkins.Overview.ActionSheet.editTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.setEditing(true, animated: true)
				self?.updateFor(isEditing: true)
			}
		)
		actionSheet.addAction(editAction)

		let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel)
		actionSheet.addAction(cancelAction)

		present(actionSheet, animated: true, completion: nil)
	}

	private func didTapDeleteAllButton() {
		showAlert(
			title: AppStrings.Checkins.Overview.DeleteAllAlert.title,
			message: AppStrings.Checkins.Overview.DeleteAllAlert.message,
			cancelButtonTitle: AppStrings.Checkins.Overview.DeleteAllAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.Checkins.Overview.DeleteAllAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				let numberOfRows = self.viewModel.numberOfRows(in: CheckinsOverviewViewModel.Section.entries.rawValue)

				self.isAllowedToReload = false
				self.viewModel.removeAll()
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(
						at: (0..<numberOfRows).map {
							IndexPath(row: $0, section: CheckinsOverviewViewModel.Section.entries.rawValue)
						},
						with: .automatic
					)
				}, completion: { _ in
					self.isAllowedToReload = true

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
