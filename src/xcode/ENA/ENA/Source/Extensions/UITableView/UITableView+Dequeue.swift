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

import UIKit

extension UITableView {
	/// Dequeue cell for the UITableView.
	/// - Parameters:
	///   - cellType: Concreate cell type.
	///   - indexPath: IndexPath of the cell.
	func dequeueReusableCell<Cell: UITableViewCell>(cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
		let identifier = cellType.cellIdentifier
		guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
			fatalError("\(identifier) isn't registered")
		}
		return cell
	}
}

extension UITableView {
	/// Registers cell's nibs for the UITableView, nib file name must be the same as cell type.
	/// - Parameters:
	///   - cellTypes: Concreate cell types.
	///   - bundle: Bundle of nib, by default nil.
	func register<Cell: UITableViewCell>(cellTypes: [Cell.Type], bunde: Bundle? = nil) {
		for cellType in cellTypes {
			let identifier = cellType.cellIdentifier
			let nib = UINib(nibName: identifier, bundle: bunde)
			register(nib, forCellReuseIdentifier: identifier)
		}
	}
}
