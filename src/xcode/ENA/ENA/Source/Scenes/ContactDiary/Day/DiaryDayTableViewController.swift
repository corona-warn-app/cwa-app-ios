////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class DiaryDayTableViewController: UITableViewController {

	// MARK: - Init

	init(
		diaryDayService: DiaryDayService,
		onAddEntryCellTap: @escaping (DiaryDay, DiaryEntryType) -> Void
	) {
		self.diaryDayService = diaryDayService
		self.onAddEntryCellTap = onAddEntryCellTap

		super.init(style: .plain)

		diaryDayService.$day
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = diaryDayService.day.formattedDate

		setupTableView()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return diaryDayService.day.entries.count
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			onAddEntryCellTap(diaryDayService.day, .contactPerson)
		case 1:
			diaryDayService.toggle(entry: diaryDayService.day.entries[indexPath.row])
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let diaryDayService: DiaryDayService
	private let onAddEntryCellTap: (DiaryDay, DiaryEntryType) -> Void

	private var subscriptions = [AnyCancellable]()

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: DiaryDayAddTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryDayAddTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: DiaryDayEntryTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: DiaryDayEntryTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
	}

	private func addCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayAddTableViewCell.self), for: indexPath) as? DiaryDayAddTableViewCell else {
			fatalError("Could not dequeue DiaryDayAddTableViewCell")
		}

		cell.configure(entryType: .contactPerson)

		return cell
	}

	private func entryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryDayEntryTableViewCell.self), for: indexPath) as? DiaryDayEntryTableViewCell else {
			fatalError("Could not dequeue DiaryDayEntryTableViewCell")
		}

		cell.configure(entry: diaryDayService.day.entries[indexPath.row])

		return cell
	}

}
