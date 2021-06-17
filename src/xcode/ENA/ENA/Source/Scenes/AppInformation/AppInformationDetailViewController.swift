//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class AppInformationDetailViewController: DynamicTableViewController, DismissHandling {
	
	var separatorStyle: UITableViewCell.SeparatorStyle = .none { didSet { tableView?.separatorStyle = separatorStyle } }
	var dismissHandling: (() -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.backgroundColor = .enaColor(for: .background)
		tableView.separatorColor = .enaColor(for: .hairline)
		tableView.allowsSelection = true
		tableView.separatorStyle = separatorStyle

		tableView.register(AppInformationLegalCell.self, forCellReuseIdentifier: CellReuseIdentifier.legal.rawValue)
		tableView.register(DynamicTableViewHtmlCell.self, forCellReuseIdentifier: CellReuseIdentifier.html.rawValue)
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: CellReuseIdentifier.legalDetails.rawValue
		)
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
	
	// the completion is currently only passed in the Submission flow with +ve test result case to display warning popup, for other flows or other test results we should dismiss normally
	func wasAttemptedToBeDismissed() {
		guard let completion = dismissHandling else {
			dismiss(animated: true, completion: nil)
			return
		}
		completion()
	}
}


extension AppInformationDetailViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case legal = "legalCell"
		case html = "htmlCell"
		case legalDetails = "DynamicLegalCell"
	}
}

extension AppInformationDetailViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url)
		return false
	}
}
