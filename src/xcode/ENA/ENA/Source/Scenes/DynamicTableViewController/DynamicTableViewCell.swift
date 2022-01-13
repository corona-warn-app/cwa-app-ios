//
// 🦠 Corona-Warn-App
//

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
		case iconWithLinkText = "iconWithLinkText"
		case space = "spaceCell"
		case bulletPoint = "bulletPointCell"
		case headlineWithImage = "headerWithImage"
		case doubleLabel = "doubleLabel"
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
	
	static func identifier(_ identifier: TableViewCellReuseIdentifiers, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, tag: String? = nil, configure: CellConfigurator? = nil) -> Self {
		.init(
			cellReuseIdentifier: identifier,
			action: action,
			accessoryAction: accessoryAction,
			configure: configure,
			tag: tag
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
	
	enum ImageAlignment {
		case left
		case right
	}
	
	static func dynamicType(text: String, cellStyle: TextCellStyle = .label, size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.identifier(cellStyle.reuseIdentifier, action: action, accessoryAction: accessoryAction) { viewController, cell, indexPath in
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
	
	static func doubleLabels(
		text1: String,
		text2: String,
		style: ENAFont = .body,
		accessibilityIdentifier1: String? = nil,
		accessibilityIdentifier2: String? = nil,
		accessibilityTraits1: UIAccessibilityTraits = .staticText,
		accessibilityTraits2: UIAccessibilityTraits = .staticText,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(CellReuseIdentifier.doubleLabel) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicTableViewDoubleLabelViewCell else { return }
			
			cell.configure(
				text1: text1,
				text2: text2,
				style: style,
				accessibilityIdentifier1: accessibilityIdentifier1,
				accessibilityIdentifier2: accessibilityIdentifier2,
				accessibilityTraits1: accessibilityTraits1,
				accessibilityTraits2: accessibilityTraits2
			)

		configure?(viewController, cell, indexPath)
		}
	}
	

	static func textWithLinks(
		text: String,
		links: [String: String],
		linksColor: UIColor = .enaColor(for: .textTint),
		style: ENAFont = .body,
		accessibilityIdentifier: String? = nil,
		accessibilityTraits: UIAccessibilityTraits = .staticText,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(CellReuseIdentifier.dynamicTypeTextView) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicTableViewTextViewCell else { return }
			cell.configureAccessibility(
				label: text,
				identifier: accessibilityIdentifier,
				traits: accessibilityTraits
			)
			cell.configure(
				text: text,
				textFont: style,
				links: links,
				linksColor: linksColor
			)

			configure?(viewController, cell, indexPath)
		}
	}

	/// Creates a text with an icon next to it.
	static func icon(
		_ image: UIImage?,
		imageAlignment: ImageAlignment = .left,
		text: DynamicTableViewIconCell.Text,
		tintColor: UIColor? = nil,
		style: ENAFont = .body,
		iconWidth: CGFloat = 32,
		selectionStyle: UITableViewCell.SelectionStyle = .none,
		action: DynamicAction = .none,
		configure: CellConfigurator? = nil,
		alignment: UIStackView.Alignment = .center
	) -> Self {
		.identifier(
			CellReuseIdentifier.icon,
			action: action,
			accessoryAction: .none, configure: { viewController, cell, indexPath in
				guard let cell = cell as? DynamicTableViewIconCell else {
					Log.error("no DynamicTableViewIconCell")
					return
				}
				cell.configure(
					image: image,
					imageAlignment: imageAlignment,
					text: text,
					customTintColor: tintColor,
					style: style,
					iconWidth: iconWidth,
					selectionStyle: selectionStyle,
					alignment: alignment
				)
				configure?(viewController, cell, indexPath)
			}
		)
	}
	
	static func iconWithLinkText(
			_ image: UIImage?,
			imageAlignment: ImageAlignment = .left,
			text: String,
			links: [ENALinkedTextView.Link],
			tintColor: UIColor? = .enaColor(for: .tint),
			style: ENAFont = .body,
			iconWidth: CGFloat = 32,
			selectionStyle: UITableViewCell.SelectionStyle = .none,
			action: DynamicAction = .none,
			configure: CellConfigurator? = nil,
			alignment: UIStackView.Alignment = .center
	) -> Self {
		.identifier(
			CellReuseIdentifier.iconWithLinkText,
			action: action,
			accessoryAction: .none, configure: { viewController, cell, indexPath in
				guard let cell = cell as? DynamicTableViewIconWithLinkTextCell else {
					Log.error("no DynamicTableViewIconCell")
					return
				}
				cell.configure(
					image: image,
					imageAlignment: imageAlignment,
					text: text,
					links: links,
					customTintColor: tintColor,
					style: style,
					iconWidth: iconWidth,
					selectionStyle: selectionStyle,
					alignment: alignment
				)
				configure?(viewController, cell, indexPath)
			}
		)
	}
	
	static func space(height: CGFloat, color: UIColor = .clear) -> Self {
		.identifier(CellReuseIdentifier.space) { _, cell, _ in
			guard let cell = cell as? DynamicTableViewSpaceCell else { return }
			cell.height = height
			cell.backgroundColor = color
		}
	}

	static func bulletPoint(
		text: String,
		spacing: DynamicTableViewBulletPointCell.Spacing = .normal,
		alignment: DynamicTableViewBulletPointCell.Alignment = .normal,
		accessibilityIdentifier: String? = nil,
		accessibilityTraits: UIAccessibilityTraits = .staticText,
		action: DynamicAction = .none,
		configure: CellConfigurator? = nil
	) -> Self {
		.bulletPoint(
			attributedText: NSAttributedString(string: text),
			spacing: spacing,
			alignment: alignment,
			accessibilityIdentifier: accessibilityIdentifier,
			accessibilityTraits: accessibilityTraits,
			action: action,
			configure: configure
		)
	}
	
	static func bulletPoint(
		attributedText: NSAttributedString,
		spacing: DynamicTableViewBulletPointCell.Spacing = .normal,
		alignment: DynamicTableViewBulletPointCell.Alignment = .normal,
		accessibilityIdentifier: String? = nil,
		accessibilityTraits: UIAccessibilityTraits = .staticText,
		action: DynamicAction = .none,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(CellReuseIdentifier.bulletPoint, action: action, accessoryAction: .none) { viewController, cell, indexPath in
			(cell as? DynamicTableViewBulletPointCell)?.configure(
				attributedString: attributedText,
				spacing: spacing,
				alignment: alignment,
				accessibilityTraits: accessibilityTraits,
				accessibilityIdentifier: accessibilityIdentifier
			)
			configure?(viewController, cell, indexPath)
		}
	}
	
	static func headlineWithImage(
		headerText: String,
		topInset: CGFloat = 64.0,
		font: ENAFont = .title1,
		image: UIImage,
		imageAccessibilityLabel: String? = nil,
		imageAccessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(CellReuseIdentifier.headlineWithImage, action: .none, accessoryAction: .none) { viewController, cell, indexPath in
			(cell as? DynamicTableViewHeadlineWithImageCell)?.configure(
				headline: headerText,
				image: image,
				topInset: topInset,
				imageAccessibilityLabel: imageAccessibilityLabel,
				imageAccessibilityIdentifier: imageAccessibilityIdentifier
			)
			configure?(viewController, cell, indexPath)
		}
	}
	
}

extension DynamicCell {
	private static func enaLabelStyle(_ style: ENALabel.Style, text: String, cellStyle: TextCellStyle = .label, color: UIColor?, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, action: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		dynamicType(text: text, cellStyle: cellStyle, size: style.fontSize, weight: UIFont.Weight(style.fontWeight), style: style.textStyle, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, action: action, configure: configure)
	}
	
	static func title1(text: String, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = [.header, .staticText], configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.title1, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}
	
	static func title2(text: String, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = [.header, .staticText], action: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.title2, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, action: action, configure: configure)
	}
	
	static func headline(text: String, style: TextCellStyle = .label, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, action: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.headline, text: text, cellStyle: style, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, action: action, configure: configure)
	}
	
	static func body(text: String, style: TextCellStyle = .label, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, action: DynamicAction = .none, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.body, text: text, cellStyle: style, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, action: action, configure: configure)
	}
	
	static func subheadline(text: String, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.subheadline, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}
	
	static func link(placeholder: String, link: String, font: ENAFont, style: ENALabel.Style, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		dynamicType(text: link, cellStyle: .linkTextView(placeholder, font), size: style.fontSize, weight: UIFont.Weight(style.fontWeight), style: style.textStyle, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}
	
	static func footnote(text: String, color: UIColor? = nil, accessibilityIdentifier: String? = nil, accessibilityTraits: UIAccessibilityTraits = .staticText, configure: CellConfigurator? = nil) -> Self {
		.enaLabelStyle(.footnote, text: text, color: color, accessibilityIdentifier: accessibilityIdentifier, accessibilityTraits: accessibilityTraits, configure: configure)
	}
	
}
