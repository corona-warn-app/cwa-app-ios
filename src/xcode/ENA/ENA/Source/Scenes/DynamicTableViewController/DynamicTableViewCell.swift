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
	var tag: String?

	func configure(cell: UITableViewCell, at indexPath: IndexPath, for viewController: DynamicTableViewController) {
		configure?(viewController, cell, indexPath)
	}
}

extension DynamicCell {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case dynamicTypeLabel = "labelCell"
		case dynamicTypeTextView = "textViewCell"
		case icon = "iconCell"
		case space = "spaceCell"
	}

	/// Style of  `DynamicTableViewTextCell`
	///
	/// These now come in two flavors:
	/// - `UILabel` backed
	/// - `UITextView` backed
	enum TextCellStyle {
		/// DynamicCell with a basic label
		case label
		/// DynamicCell that uses a UITextView with data recognizers instead of a UILabel to display text
		/// Useful for automatic link, phone #, etc. recognization
		case textView(UIDataDetectorTypes)

		case linkTextView(String, ENAFont = .body)

		var reuseIdentifier: CellReuseIdentifier {
			switch self {
			case .label: return .dynamicTypeLabel
			case .textView: return .dynamicTypeTextView
			case .linkTextView: return .dynamicTypeTextView
			}
		}
	}

	static func identifier(_ identifier: TableViewCellReuseIdentifiers, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.init(
			cellReuseIdentifier: identifier,
			action: action,
			accessoryAction: accessoryAction,
			configure: configure,
			tag: nil
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
	static func dynamicType(text: String, cellStyle: TextCellStyle = .label, size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.identifier(cellStyle.reuseIdentifier, action: .none, accessoryAction: .none) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicTableViewTextCell else { return }

			cell.configureDynamicType(size: size, weight: weight, style: style)
			cell.configure(text: text, color: color)
			cell.configureAccessibility(label: text, identifier: accessibilityIdentifier, traits: accessibilityTraits)

			if case .textView(let dataDetectorTypes) = cellStyle,
				let cell = cell as? DynamicTableViewTextViewCell {
				cell.configureTextView(dataDetectorTypes: dataDetectorTypes)
			}

			if case .linkTextView(let placeHolder, let font) = cellStyle,
				let cell = cell as? DynamicTableViewTextViewCell {
				cell.configureAsLink(placeholder: placeHolder, urlString: text, font: font)
			}

			configure?(viewController, cell, indexPath)
		}
	}

	static func icon(_ image: UIImage?, text: String, tintColor: UIColor? = nil, style: ENAFont = .body, action: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.identifier(CellReuseIdentifier.icon, action: action, accessoryAction: .none) { viewController, cell, indexPath in
			(cell as? DynamicTableViewIconCell)?.configure(image: image, text: text, tintColor: tintColor, style: style)
			configure?(viewController, cell, indexPath)
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
	private static func enaLabelStyle(_ style: ENALabel.Style, text: String, cellStyle: TextCellStyle = .label, color: UIColor?, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		dynamicType(text: text, cellStyle: cellStyle, size: style.fontSize, weight: UIFont.Weight(style.fontWeight), style: style.textStyle, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}

	static func title1(text: String, color: UIColor? = nil, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = [.header, .staticText], configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.title1, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}

	static func title2(text: String, color: UIColor? = nil, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = [.header, .staticText], configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.title2, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}

	static func headline(text: String, color: UIColor? = nil, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.headline, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}

	static func body(text: String, style: TextCellStyle = .label, color: UIColor? = nil, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.body, text: text, cellStyle: style, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}

	static func subheadline(text: String, color: UIColor? = nil, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.subheadline, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}

	static func footnote(text: String, color: UIColor? = nil, accessibilityIdentifier: String?, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.footnote, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}
}
