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
		navigationItem.title = AppStrings.RecycleBin.title

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

		footerView?.update(to: editing ? .primary : .none)
		animateCellHeightChanges()
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

		shouldReload = false
		viewModel.removeEntry(at: indexPath)

		tableView.performBatchUpdates({
			var indexPaths = [indexPath]

			if self.viewModel.isEmpty {
				indexPaths.append(IndexPath(row: 0, section: RecycleBinViewModel.Section.description.rawValue))
			}

			tableView.deleteRows(at: indexPaths, with: .automatic)
		}, completion: { _ in
			self.shouldReload = true

			if self.viewModel.isEmpty {
				self.setEditing(false, animated: true)
				self.updateEmptyState()
			}
		})
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch RecycleBinViewModel.Section(rawValue: indexPath.section) {
		case .description:
			break
		case .entries:
			showRestoreAlert(forItemAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		// This empty implementation prevents the table view from going into editing mode as we don't want to show the "Delete all" and "Done" buttons on swipe to delete.
	}

	// MARK: - Private

	private let viewModel: RecycleBinViewModel

	private var subscriptions = [AnyCancellable]()
	private var shouldReload = true

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
	}

	private func animateCellHeightChanges() {
		DispatchQueue.main.async { [self] in
			tableView.performBatchUpdates(nil, completion: nil)
		}
	}

	private func descriptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DynamicTypeTableViewCell.self), for: indexPath) as? DynamicTypeTableViewCell else {
			fatalError("Could not dequeue ExposureSubmissionCheckinDescriptionTableViewCell")
		}

		cell.configure(
			text: AppStrings.RecycleBin.description,
			color: .enaColor(for: .textPrimary2)
		)

		let style: ENALabel.Style = .body
		cell.configureDynamicType(
			size: style.fontSize,
			weight: UIFont.Weight(style.fontWeight),
			style: style.textStyle
		)

		cell.backgroundColor = .enaColor(for: .darkBackground)

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
		tableView.backgroundView = viewModel.isEmpty
			? EmptyStateView(
				viewModel: RecycleBinEmptyStateViewModel(),
				safeInsetTop: tableView.adjustedContentInset.top,
				alignmentPadding: UIScreen.main.bounds.height / 3
			)
			: nil

		navigationItem.rightBarButtonItem = viewModel.isEmpty ? nil : editButtonItem
	}

	private func didTapDeleteAllButton() {
		showAlert(
			title: AppStrings.RecycleBin.DeleteAllAlert.title,
			message: AppStrings.RecycleBin.DeleteAllAlert.message,
			cancelButtonTitle: AppStrings.RecycleBin.DeleteAllAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.RecycleBin.DeleteAllAlert.confirmButtonTitle,
			confirmButtonStyle: .destructive,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				let numberOfRows = self.viewModel.recycleBinItems.count

				self.shouldReload = false
				self.viewModel.removeAll()
				self.tableView.performBatchUpdates({
					var indexPaths = (0..<numberOfRows)
						.map {
							IndexPath(row: $0, section: RecycleBinViewModel.Section.entries.rawValue)
						}

					indexPaths.append(IndexPath(row: 0, section: RecycleBinViewModel.Section.description.rawValue))

					self.tableView.deleteRows(at: indexPaths, with: .automatic)
				}, completion: { _ in
					self.shouldReload = true

					self.setEditing(false, animated: true)
					self.updateEmptyState()
				})
			}
		)
	}

	private func showRestoreAlert(forItemAt indexPath: IndexPath) {
		switch viewModel.recycleBinItems[indexPath.row].item {
		case .certificate:
			showAlert(
				title: AppStrings.RecycleBin.RestoreCertificateAlert.title,
				message: AppStrings.RecycleBin.RestoreCertificateAlert.message,
				cancelButtonTitle: AppStrings.RecycleBin.RestoreCertificateAlert.cancelButtonTitle,
				confirmButtonTitle: AppStrings.RecycleBin.RestoreCertificateAlert.confirmButtonTitle,
				confirmButtonStyle: .default,
				confirmAction: { [weak self] in
					self?.viewModel.restoreItem(at: indexPath)
				}
			)
		case .userCoronaTest, .familyMemberCoronaTest:
			showAlert(
				title: AppStrings.RecycleBin.RestoreCoronaTestAlert.title,
				message: AppStrings.RecycleBin.RestoreCoronaTestAlert.message,
				cancelButtonTitle: AppStrings.RecycleBin.RestoreCoronaTestAlert.cancelButtonTitle,
				confirmButtonTitle: AppStrings.RecycleBin.RestoreCoronaTestAlert.confirmButtonTitle,
				confirmButtonStyle: .default,
				confirmAction: { [weak self] in
					self?.viewModel.restoreItem(at: indexPath)
				}
			)
		}
	}

	private func showAlert(
		title: String,
		message: String,
		cancelButtonTitle: String,
		confirmButtonTitle: String,
		confirmButtonStyle: UIAlertAction.Style,
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

		let confirmAlertAction = UIAlertAction(
			title: confirmButtonTitle,
			style: confirmButtonStyle,
			handler: { _ in
				confirmAction()
			}
		)
		confirmAlertAction.accessibilityIdentifier = AccessibilityIdentifiers.RecycleBin.restorationConfirmationButton
		alert.addAction(confirmAlertAction)

		present(alert, animated: true, completion: nil)
	}

}
