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

enum DynamicCell {
	typealias GenericCellConfigurator<T: DynamicTableViewController> = (_ viewController: T, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void
	typealias CellConfigurator = GenericCellConfigurator<DynamicTableViewController>

	case bigBold(text: String)
	case bold(text: String)
	case semibold(text: String)
	case regular(text: String)
	case icon(action: DynamicAction = .none, DynamicIcon)
	case identifier(
		_ identifier: TableViewCellReuseIdentifiers,
		action: DynamicAction = .none,
		accessoryAction: DynamicAction = .none,
		configure: CellConfigurator? = nil
	)

	static func custom<T: DynamicTableViewController>(
		withIdentifier identifier: TableViewCellReuseIdentifiers,
		action: DynamicAction = .none,
		accessoryAction: DynamicAction = .none,
		configure: GenericCellConfigurator<T>? = nil
	) -> Self {
		.identifier(identifier, action: action, accessoryAction: accessoryAction) { viewController, cell, indexPath in
			if let viewCtrl = viewController as? T {
				configure?(viewCtrl, cell, indexPath)
			} else {
				fatalError("This cell type may not be used on view controller of type: " + String(describing: T.self))
			}
		}
	}

	var action: DynamicAction {
		switch self {
		case let .icon(action, _):
			return action
		case let .identifier(_, action, _, _):
			return action
		default:
			return .none
		}
	}

	var accessoryAction: DynamicAction {
		switch self {
		case let .identifier(_, _, accessoryAction, _):
			return accessoryAction
		default:
			return .none
		}
	}
}
