// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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
