//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class RiskLegendViewController: DynamicTableViewController {

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = AppStrings.RiskLegend.title

		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: { [weak self] in
			self?.dismiss(animated: true)
		})

		view.backgroundColor = .enaColor(for: .background)

		tableView.separatorStyle = .none
		tableView.allowsSelection = false

		tableView.register(
			UINib(nibName: String(describing: RiskLegendDotBodyCell.self), bundle: nil),
			forCellReuseIdentifier: CellReuseIdentifier.dotBody.rawValue
		)

		dynamicTableViewModel = model
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)

		cell.backgroundColor = .clear

		return cell
	}

}

extension RiskLegendViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case dotBody = "RiskLegendDotBodyCell"
	}
}
