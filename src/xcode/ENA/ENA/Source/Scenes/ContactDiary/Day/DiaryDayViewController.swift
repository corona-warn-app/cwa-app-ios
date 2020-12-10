////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class DiaryDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Init

	init(
		viewModel: DiaryDayViewModel,
		onAddEntryCellTap: @escaping (DiaryDay, DiaryEntryType) -> Void
	) {
		self.viewModel = viewModel
		self.onAddEntryCellTap = onAddEntryCellTap

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

		setupSegmentedControl()
		setupTableView()

		viewModel.$day
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)

		viewModel.$selectedEntryType
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				// Scrolling to top prevents table view from flickering while reloading
				self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return viewModel.entriesOfSelectedType.count
		default:
			fatalError("Invalid section")
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			return addCell(forRowAt: indexPath)
		case 1:
			return entryCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			onAddEntryCellTap(viewModel.day, viewModel.selectedEntryType)
		case 1:
			viewModel.toggle(entry: viewModel.entriesOfSelectedType[indexPath.row])
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: DiaryDayViewModel
	private let onAddEntryCellTap: (DiaryDay, DiaryEntryType) -> Void

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

	private func addCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayAddTableViewCell.self), for: indexPath) as? DiaryDayAddTableViewCell else {
			fatalError("Could not dequeue DiaryDayAddTableViewCell")
		}

		cell.configure(entryType: viewModel.selectedEntryType)

		return cell
	}

	private func entryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayEntryTableViewCell.self), for: indexPath) as? DiaryDayEntryTableViewCell else {
			fatalError("Could not dequeue DiaryDayEntryTableViewCell")
		}

		cell.configure(entry: viewModel.entriesOfSelectedType[indexPath.row])

		return cell
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
