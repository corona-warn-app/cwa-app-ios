//
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayNotesInfoViewController: DynamicTableViewController {

	// MARK: - Initializers
	
	init(
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = DiaryDayNotesInfoViewModel()

		super.init(nibName: nil, bundle: nil)

		navigationItem.rightBarButtonItem = CloseBarButtonItem {
			onDismiss()
		}

		navigationItem.title = AppStrings.ContactDiary.NotesInformation.title
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle Methods

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
	}

	// MARK: - Private API

	private let viewModel: DiaryDayNotesInfoViewModel

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
}

// MARK: - Cell reuse identifiers.

private extension DiaryDayNotesInfoViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
