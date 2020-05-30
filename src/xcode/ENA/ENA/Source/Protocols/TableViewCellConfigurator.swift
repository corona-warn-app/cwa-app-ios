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

protocol TableViewCellConfiguratorAny {
	var viewAnyType: UITableViewCell.Type { get }

	func configureAny(cell: UITableViewCell)
}

protocol TableViewCellConfigurator: TableViewCellConfiguratorAny {
	associatedtype CellType: UITableViewCell
	func configure(cell: CellType)
}

extension TableViewCellConfigurator {
	var viewAnyType: UITableViewCell.Type {
		CellType.self
	}

	func configureAny(cell: UITableViewCell) {
		if let cell = cell as? CellType {
			configure(cell: cell)
		} else {
			let error = "\(cell) isn't conformed CellType"
			logError(message: error)
			fatalError(error)
		}
	}
}
