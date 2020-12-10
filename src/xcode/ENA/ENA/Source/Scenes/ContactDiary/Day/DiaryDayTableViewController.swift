////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayTableViewController: UITableViewController {

	// MARK: - Init

	init(
		diaryDayService: DiaryDayService,
		onAddEntryCellTap: @escaping (DiaryDay, DiaryEntryType) -> Void
	) {
		self.diaryDayService = diaryDayService
		self.onAddEntryCellTap = onAddEntryCellTap

		super.init(style: .plain)
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
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return 0
	}

//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//
//		// Configure the cell...
//
//		return cell
//	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

	}

	// MARK: - Private

	private let diaryDayService: DiaryDayService
	private let onAddEntryCellTap: (DiaryDay, DiaryEntryType) -> Void

}
