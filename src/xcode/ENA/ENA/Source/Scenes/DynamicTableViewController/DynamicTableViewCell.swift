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

struct DynamicCell {
	typealias GenericCellConfigurator<T: DynamicTableViewController> = (_ viewController: T, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void
	typealias CellConfigurator = GenericCellConfigurator<DynamicTableViewController>

	let cellReuseIdentifier: TableViewCellReuseIdentifiers
	let action: DynamicAction
	let accessoryAction: DynamicAction
	private let configure: CellConfigurator?

	func configure(cell: UITableViewCell, at indexPath: IndexPath, for viewController: DynamicTableViewController) {
		configure?(viewController, cell, indexPath)
	}
}

extension DynamicCell {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case dynamicTypeText = "regularCell"
		case icon = "iconCell"
		case space = "spaceCell"
	}

	static func identifier(_ identifier: TableViewCellReuseIdentifiers, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.init(
			cellReuseIdentifier: identifier,
			action: action,
			accessoryAction: accessoryAction,
			configure: configure
		)
	}

	static func custom<T: DynamicTableViewController>(withIdentifier identifier: TableViewCellReuseIdentifiers, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, configure: GenericCellConfigurator<T>? = nil) -> Self {
		.identifier(identifier, action: action, accessoryAction: accessoryAction) { viewController, cell, indexPath in
			if let viewController = viewController as? T {
				configure?(viewController, cell, indexPath)
			} else {
				fatalError("This cell type may not be used on view controller of type: " + String(describing: T.self))
			}
		}
	}
}

extension DynamicCell {
	static func dynamicType(text: String, size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self {
		.identifier(CellReuseIdentifier.dynamicTypeText, action: .none, accessoryAction: .none) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicTypeTableViewCell else { return }
			cell.configureDynamicType(size: size, weight: weight, style: style)
			cell.configure(text: text, color: color)
			configure?(viewController, cell, indexPath)
		}
	}

	static func icon(action: DynamicAction = .none, _ icon: DynamicIcon) -> Self {
		.identifier(CellReuseIdentifier.icon, action: action, accessoryAction: .none) { _, cell, _ in
			(cell as? DynamicTableViewIconCell)?.configure(icon)
		}
	}

	static func space(height: CGFloat, color: UIColor? = nil) -> Self {
		.identifier(CellReuseIdentifier.space) { _, cell, _ in
			guard let cell = cell as? DynamicTableViewSpaceCell else { return }
			cell.height = height
			cell.backgroundColor = color
		}
	}
}

extension DynamicCell {
	private static func enaLabelStyle(_ style: ENALabel.Style, text: String, color: UIColor? = .preferredColor(for: .textPrimary1), configure: CellConfigurator? = nil) -> Self {
		dynamicType(text: text, size: style.fontSize, weight: UIFont.Weight(style.fontWeight), style: style.textStyle, color: color, configure: configure)
	}

	static func title1(text: String, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self { .enaLabelStyle(.title1, text: text, color: color, configure: configure) }
	static func title2(text: String, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self { .enaLabelStyle(.title2, text: text, color: color, configure: configure) }
	static func headline(text: String, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self { .enaLabelStyle(.headline, text: text, color: color, configure: configure) }
	static func body(text: String, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self { .enaLabelStyle(.body, text: text, color: color, configure: configure) }
	static func subheadline(text: String, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self { .enaLabelStyle(.subheadline, text: text, color: color, configure: configure) }
	static func footnote(text: String, color: UIColor? = nil, configure: CellConfigurator? = nil) -> Self { .enaLabelStyle(.footnote, text: text, color: color, configure: configure) }
}

extension DynamicCell {
	// TODO to be removed
	@available(*, deprecated, renamed: "title2")
	static func bigBold(text: String) -> Self { .dynamicType(text: text, size: 22, weight: .bold, style: .headline) }
	@available(*, deprecated)
	static func bold(text: String) -> Self { .dynamicType(text: text, size: 17, weight: .bold, style: .body) }
	@available(*, deprecated, renamed: "headline")
	static func semibold(text: String) -> Self { .dynamicType(text: text, size: 17, weight: .semibold, style: .body) }
	@available(*, deprecated, renamed: "body")
	static func regular(text: String) -> Self { .dynamicType(text: text, size: 17, weight: .regular, style: .body) }
}
