//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol TableViewSections {
	var rawValue: Int { get }

	init?(rawValue: Int)
	init?(_ section: Int)
	init?(_ indexPath: IndexPath)
}

extension TableViewSections {
	init?(_ section: Int) {
		self.init(rawValue: section)
	}

	init?(_ indexPath: IndexPath) {
		self.init(indexPath.section)
	}
}

protocol TableViewReuseIdentifiers {
	var rawValue: String { get }

	init?(rawValue: String)
	init?(_ identifier: String)
}

extension TableViewReuseIdentifiers {
	init?(_ identifier: String) {
		self.init(rawValue: identifier)
	}
}

protocol TableViewHeaderFooterReuseIdentifiers: TableViewReuseIdentifiers {}

protocol TableViewCellReuseIdentifiers: TableViewReuseIdentifiers {}

extension UITableView {
	typealias HeaderFooterReuseIdentifier = TableViewHeaderFooterReuseIdentifiers
	typealias CellReuseIdentifier = TableViewCellReuseIdentifiers

	func dequeueReusableHeaderFooterView(withIdentifier identifier: HeaderFooterReuseIdentifier) -> UITableViewHeaderFooterView? {
		dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue)
	}

	func dequeueReusableCell(withIdentifier identifier: CellReuseIdentifier) -> UITableViewCell? {
		dequeueReusableCell(withIdentifier: identifier.rawValue)
	}

	func dequeueReusableCell(withIdentifier identifier: CellReuseIdentifier, for indexPath: IndexPath) -> UITableViewCell {
		dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
	}
}
