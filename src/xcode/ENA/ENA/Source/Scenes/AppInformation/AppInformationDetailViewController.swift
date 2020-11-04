import Foundation
import UIKit

class AppInformationDetailViewController: DynamicTableViewController {
	var separatorStyle: UITableViewCell.SeparatorStyle = .none { didSet { tableView?.separatorStyle = separatorStyle } }

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.backgroundColor = .enaColor(for: .background)
		tableView.separatorColor = .enaColor(for: .hairline)
		tableView.allowsSelection = true
		tableView.separatorStyle = separatorStyle

		tableView.register(AppInformationLegalCell.self, forCellReuseIdentifier: CellReuseIdentifier.legal.rawValue)
		tableView.register(DynamicTableViewHtmlCell.self, forCellReuseIdentifier: CellReuseIdentifier.html.rawValue)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear

		if dynamicTableViewModel.cell(at: indexPath).tag == "phone" {
			cell.selectionStyle = .default
		} else {
			cell.selectionStyle = .none
		}

		return cell
	}
}


extension AppInformationDetailViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case legal = "legalCell"
		case html = "htmlCell"
	}
}

extension AppInformationDetailViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(withUrl: url, from: self)
		return false
	}
}
