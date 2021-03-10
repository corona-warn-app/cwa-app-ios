//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationsOverviewViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: TraceLocationsOverviewViewModel,
		onInfoButtonTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoButtonTap = onInfoButtonTap

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

		setupTableView()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.TraceLocations.Overview.title

		updateRightBarButtonItem()

		viewModel.$traceLocations
			.sink { [weak self] _ in
				DispatchQueue.main.async {
					self?.update()
				}
			}
			.store(in: &subscriptions)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return traceLocationAddCell(forRowAt: indexPath)
		case .entries:
			return traceLocationCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			viewModel.didTapAddEntryCell()
		case .entries:
			viewModel.didTapEntryCell(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		updateRightBarButtonItem()
	}

	// MARK: - Private

	private let viewModel: TraceLocationsOverviewViewModel

	private let onInfoButtonTap: () -> Void

	private var subscriptions = [AnyCancellable]()

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddTraceLocationTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddTraceLocationTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: TraceLocationTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: TraceLocationTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func updateRightBarButtonItem() {
		let barButtonItem: UIBarButtonItem

		if tableView.isEditing {
			barButtonItem = editButtonItem
		} else {
			barButtonItem = UIBarButtonItem(
				image: UIImage(named: "Icons_More_Circle"),
				style: .plain,
				target: self,
				action: #selector(didTapMoreButton)
			)
			barButtonItem.accessibilityLabel = AppStrings.TraceLocations.Overview.menuButtonTitle
			barButtonItem.tintColor = .enaColor(for: .tint)
		}

		navigationItem.setRightBarButton(barButtonItem, animated: true)
	}

	private func traceLocationAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddTraceLocationTableViewCell.self), for: indexPath) as? AddTraceLocationTableViewCell else {
			fatalError("Could not dequeue DiaryDayAddTableViewCell")
		}

		let cellModel = AddTraceLocationCellModel()
		cell.configure(cellModel: cellModel)

		return cell
	}

	private func traceLocationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TraceLocationTableViewCell.self), for: indexPath) as? TraceLocationTableViewCell else {
			fatalError("Could not dequeue DiaryDayEntryTableViewCell")
		}

		let cellModel = viewModel.traceLocationCellModel(at: indexPath)
		cell.configure(
			cellModel: cellModel,
			onButtonTap: { [weak self] in
				self?.viewModel.didTapEntryCellButton(at: indexPath)
			}
		)

		return cell
	}

	private func update() {
		tableView.reloadData()

		tableView.backgroundView = viewModel.isEmpty ? EmptyStateView(viewModel: TraceLocationsOverviewEmptyStateViewModel()) : nil
	}

	@objc
	private func didTapMoreButton() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let infoAction = UIAlertAction(
			title: AppStrings.TraceLocations.Overview.ActionSheet.infoTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.onInfoButtonTap()
			}
		)
		actionSheet.addAction(infoAction)

		let editPerson = UIAlertAction(
			title: AppStrings.TraceLocations.Overview.ActionSheet.editTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.setEditing(true, animated: true)
			}
		)
		actionSheet.addAction(editPerson)

		let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel)
		actionSheet.addAction(cancelAction)

		present(actionSheet, animated: true, completion: nil)
	}

}
