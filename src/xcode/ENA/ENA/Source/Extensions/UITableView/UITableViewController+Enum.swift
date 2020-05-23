//
//  UITableViewController+Enum.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
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


protocol TableViewHeaderFooterReuseIdentifiers: TableViewReuseIdentifiers { }


protocol TableViewCellReuseIdentifiers: TableViewReuseIdentifiers { }


extension UITableView {
	typealias HeaderFooterReuseIdentifier = TableViewHeaderFooterReuseIdentifiers
	typealias CellReuseIdentifier = TableViewCellReuseIdentifiers

	func dequeueReusableHeaderFooterView(withIdentifier identifier: HeaderFooterReuseIdentifier) -> UITableViewHeaderFooterView? {
		return self.dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue)
	}

	func dequeueReusableCell(withIdentifier identifier: CellReuseIdentifier) -> UITableViewCell? {
		return self.dequeueReusableCell(withIdentifier: identifier.rawValue)
	}
	
	func dequeueReusableCell(withIdentifier identifier: CellReuseIdentifier, for indexPath: IndexPath) -> UITableViewCell {
		return self.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
	}
}
