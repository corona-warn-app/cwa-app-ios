//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class EventPlanningOverviewViewController: UITableViewController {

	// MARK: - Init

	init(
		viewModel: EventPlanningOverviewViewModel,
		onAddEventCellTap: @escaping () -> Void,
		onEventCellTap: @escaping (/* Event */) -> Void
	) {
		self.viewModel = viewModel
		self.onAddEventCellTap = onAddEventCellTap
		self.onEventCellTap = onEventCellTap

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.EventPlanning.Overview.title

		view.backgroundColor = .enaColor(for: .darkBackground)

		setupTableView()

//		viewModel.$day
//			.sink { [weak self] _ in
//				DispatchQueue.main.async {
//					self?.update()
//				}
//			}
//			.store(in: &subscriptions)

		// Can be removed once publisher is active
		update()
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
			return eventAddCell(forRowAt: indexPath)
		case .entries:
			return eventCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			onAddEventCellTap()
		case .entries:
			break
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: EventPlanningOverviewViewModel
	private let onAddEventCellTap: () -> Void
	private let onEventCellTap: () -> Void

	private var subscriptions = [AnyCancellable]()

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddEventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddEventTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: EventTableViewCell.self)
		)

		tableView.delegate = self
		tableView.dataSource = self

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func eventAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddEventTableViewCell.self), for: indexPath) as? AddEventTableViewCell else {
			fatalError("Could not dequeue DiaryDayAddTableViewCell")
		}

		let cellModel = AddEventCellModel()
		cell.configure(cellModel: cellModel)

		return cell
	}

	private func eventCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self), for: indexPath) as? EventTableViewCell else {
			fatalError("Could not dequeue DiaryDayEntryTableViewCell")
		}

		let cellModel = viewModel.eventCellModel(at: indexPath)
		cell.configure(
			cellModel: cellModel,
			onButtonTap: { [weak self] /* event */ in

			}
		)

		return cell
	}

	private func update() {
		tableView.reloadData()

		tableView.backgroundView = viewModel.isEmpty ? EmptyStateView(viewModel: EventPlanningOverviewEmptyStateViewModel()) : nil
	}

}
