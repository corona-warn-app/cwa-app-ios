////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewTableViewController: UITableViewController {

	// MARK: - Init

	init(
		diaryService: DiaryService,
		onCellSelection: @escaping (DiaryDay) -> Void,
		onInfoButtonTap: @escaping () -> Void,
		onExportButtonTap: @escaping () -> Void,
		onEditContactPersonsButtonTap: @escaping () -> Void,
		onEditLocationsButtonTap: @escaping () -> Void
	) {
		self.viewModel = DiaryOverviewViewModel(diaryService: diaryService)
		self.onCellSelection = onCellSelection
		self.onInfoButtonTap = onInfoButtonTap
		self.onExportButtonTap = onExportButtonTap
		self.onEditContactPersonsButtonTap = onEditContactPersonsButtonTap
		self.onEditLocationsButtonTap = onEditLocationsButtonTap

		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
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

	let viewModel: DiaryOverviewViewModel
	let onCellSelection: (DiaryDay) -> Void
	private let onInfoButtonTap: () -> Void
	private let onExportButtonTap: () -> Void
	private let onEditContactPersonsButtonTap: () -> Void
	private let onEditLocationsButtonTap: () -> Void

}
