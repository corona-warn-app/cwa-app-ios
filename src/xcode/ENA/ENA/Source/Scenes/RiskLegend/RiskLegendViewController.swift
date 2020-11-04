import Foundation
import UIKit

class RiskLegendViewController: DynamicTableViewController {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = AppStrings.RiskLegend.title

		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.AccessibilityLabel.close
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		dynamicTableViewModel = model
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear
		return cell
	}

	@IBAction func close() {
		dismiss(animated: true)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		navigationItem.rightBarButtonItem?.image = UIImage(named: "Icons - Close")
	}
}

extension RiskLegendViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case numberedTitle = "numberedTitleCell"
		case dotBody = "dotBodyCell"
	}
}
