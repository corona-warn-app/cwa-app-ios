////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Init

	init(
		viewModel: DiaryDayViewModel
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

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = viewModel.day.formattedDate

		view.backgroundColor = .enaColor(for: .darkBackground)

		setupSegmentedControl()
		setupTableView()

		viewModel.$day
			.receive(on: RunLoop.main.ocombine)
			.sink { [weak self] _ in
				self?.updateForSelectedEntryType()
			}
			.store(in: &subscriptions)

		viewModel.$selectedEntryType
			.sink { [weak self] _ in
				// DispatchQueue triggers immediately while .receive(on:) would wait until the main runloop is free, which lead to a crash if the switch happend while scrolling.
				// In that case cells were dequeued for the old model (entriesOfSelectedType) that was not available anymore.
				DispatchQueue.main.async {
					// Scrolling to top prevents table view from flickering while reloading
					self?.tableView.setContentOffset(.zero, animated: false)
					self?.updateForSelectedEntryType()
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return entryAddCell(forRowAt: indexPath)
		case .entries:
			return entryCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch DiaryDayViewModel.Section(rawValue: indexPath.section) {
		case .add:
			viewModel.didTapAddEntryCell()
		case .entries:
			viewModel.toggleSelection(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: DiaryDayViewModel

	private var subscriptions = [AnyCancellable]()

	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!

	private func setupSegmentedControl() {
		segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.enaFont(for: .subheadline)], for: .normal)
		segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.enaFont(for: .subheadline, weight: .bold)], for: .selected)

		segmentedControl.setTitle(AppStrings.ContactDiary.Day.contactPersonsSegment, forSegmentAt: 0)
		segmentedControl.setTitle(AppStrings.ContactDiary.Day.locationsSegment, forSegmentAt: 1)
	}

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: DiaryDayAddTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryDayAddTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: DiaryDayEntryTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryDayEntryTableViewCell.self)
		)

		tableView.delegate = self
		tableView.dataSource = self

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func entryAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayAddTableViewCell.self), for: indexPath) as? DiaryDayAddTableViewCell else {
			fatalError("Could not dequeue DiaryDayAddTableViewCell")
		}

		let cellModel = DiaryDayAddCellModel(entryType: viewModel.selectedEntryType)
		cell.configure(cellModel: cellModel)

		return cell
	}

	private func entryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayEntryTableViewCell.self), for: indexPath) as? DiaryDayEntryTableViewCell else {
			fatalError("Could not dequeue DiaryDayEntryTableViewCell")
		}

		let cellModel = DiaryDayEntryCellModel(entry: viewModel.entriesOfSelectedType[indexPath.row])
		cell.configure(cellModel: cellModel)

		return cell
	}

	private func updateForSelectedEntryType() {
		tableView.reloadData()

		tableView.backgroundView = viewModel.entriesOfSelectedType.isEmpty ? DiaryDayEmptyView(entryType: viewModel.selectedEntryType) : nil
	}

	@IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			viewModel.selectedEntryType = .contactPerson
		default:
			viewModel.selectedEntryType = .location
		}
	}

}
