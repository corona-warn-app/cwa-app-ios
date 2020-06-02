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

protocol CollectionViewCellConfiguratorAny: AnyObject {
	var viewAnyType: UICollectionViewCell.Type { get }

	func configureAny(cell: UICollectionViewCell)

	var identifier: UUID { get }
}

protocol CollectionViewCellConfigurator: CollectionViewCellConfiguratorAny {
	associatedtype CellType: UICollectionViewCell
	func configure(cell: CellType)
}

extension CollectionViewCellConfigurator {
	var viewAnyType: UICollectionViewCell.Type {
		CellType.self
	}

	func configureAny(cell: UICollectionViewCell) {
		if let cell = cell as? CellType {
			configure(cell: cell)
		} else {
			let error = "\(cell) isn't conformed CellType"
			logError(message: error)
			fatalError(error)
		}
	}
}
