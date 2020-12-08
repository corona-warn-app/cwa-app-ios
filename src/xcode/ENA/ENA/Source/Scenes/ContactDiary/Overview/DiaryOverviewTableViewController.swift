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

		tableView.register(UINib(nibName: String(describing: DiaryOverviewTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: DiaryOverviewTableViewCell.self))
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.diaryService.days.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryOverviewTableViewCell.self), for: indexPath) as? DiaryOverviewTableViewCell else {
			fatalError("Could not dequeue cell")
		}

		cell.configure(day: viewModel.diaryService.days[indexPath.row])

		return cell
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onCellSelection(viewModel.diaryService.days[indexPath.row])
	}

	// MARK: - Private

	private let viewModel: DiaryOverviewViewModel
	private let onCellSelection: (DiaryDay) -> Void
	private let onInfoButtonTap: () -> Void
	private let onExportButtonTap: () -> Void
	private let onEditContactPersonsButtonTap: () -> Void
	private let onEditLocationsButtonTap: () -> Void

}
