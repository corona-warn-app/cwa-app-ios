//
// 🦠 Corona-Warn-App
//
#if !RELEASE

import UIKit

class DMHibernationOptionsViewController: UITableViewController {
	
	// MARK: - Init
	
	init(store: Store) {
		viewModel = DMHibernationOptionsViewModel(store: store)
		
		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupNavigationBar()
		setupTableView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfRows(in: section)
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		
		if let cellViewModel = cellViewModel as? DMDatePickerCellViewModel {
			return configureHibernationComparisonDatePickerCell(cellViewModel: cellViewModel, indexPath: indexPath)

		} else if let cellViewModel = cellViewModel as? DMButtonCellViewModel {
			return configureHibernationComparisonDateResetCell(cellViewModel: cellViewModel, indexPath: indexPath)

		} else {
			return UITableViewCell()
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		viewModel.titleForFooter(in: section)
	}

	// MARK: - Private
	
	private let viewModel: DMHibernationOptionsViewModel
	
	private func setupNavigationBar() {
		title = "Hibernation Options"
	}

	private func setupTableView() {
		tableView.estimatedRowHeight = 45
		tableView.rowHeight = UITableView.automaticDimension
		
		tableView.register(DMDatePickerTableViewCell.self, forCellReuseIdentifier: DMDatePickerTableViewCell.reuseIdentifier)
		tableView.register(DMButtonTableViewCell.self, forCellReuseIdentifier: DMButtonTableViewCell.reuseIdentifier)
	}
	
	private func configureHibernationComparisonDatePickerCell(
		cellViewModel: DMDatePickerCellViewModel,
		indexPath: IndexPath
	) -> DMDatePickerTableViewCell {
		let cell = tableView.dequeueReusableCell(cellType: DMDatePickerTableViewCell.self, for: indexPath)
		cell.configure(cellViewModel: cellViewModel)
		
		cell.didSelectDate = { [weak self] hibernationComparisonDate in
			self?.viewModel.store(hibernationComparisonDate: hibernationComparisonDate)
		}
		
		return cell
	}
	
	private func configureHibernationComparisonDateResetCell(
		cellViewModel: DMButtonCellViewModel,
		indexPath: IndexPath
	) -> DMButtonTableViewCell {
		let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
		
		cell.configure(cellViewModel: cellViewModel)
		
		return cell
	}
}

#endif
