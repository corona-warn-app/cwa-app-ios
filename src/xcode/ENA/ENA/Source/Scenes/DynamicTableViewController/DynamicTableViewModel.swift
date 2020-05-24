//
//  DynamicTableViewModel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


struct DynamicTableViewModel {
	private let content: [Section]
	
	
	init(_ content: [Section]) {
		self.content = content
	}
	
	
	func section(_ section: Int) -> Section {
		return self.content[section]
	}
	
	func section(at indexPath: IndexPath) -> Section {
		return self.section(indexPath.section)
	}
	
	func cell(at indexPath: IndexPath) -> Cell {
		return self.content[indexPath.section].cells[indexPath.row]
	}
	
	
	var numberOfSection: Int { content.count }
	func numberOfRows(inSection section: Int) -> Int { self.section(section).cells.count }
	
	
	struct Section {
		let header: Header
		let footer: Footer
		let separators: Bool
		let cells: [Cell]
		
		private init(header: Header, footer: Footer, separators: Bool, cells: [Cell]) {
			self.header = header
			self.footer = footer
			self.separators = separators
			self.cells = cells
		}
		
		static func section(header: Header = .none, footer: Footer = .blank, separators: Bool = false, cells: [Cell]) -> Section {
			return .init(header: header, footer: footer, separators: separators, cells: cells)
		}
	}
	
	enum Header {
		// swiftlint:disable:next nesting
		typealias HeaderConfigurator = (_ view: UIView, _ section: Int) -> Void
		
		case none
		case blank
		case space(height: CGFloat)
		case text(_ text: String)
		case separator(color: UIColor, height: CGFloat = 1, insets: UIEdgeInsets = .zero)
		case image(_ image: UIImage?, height: CGFloat = 250)
		case view(_ view: UIView)
		case identifier(_ identifier: TableViewHeaderFooterReuseIdentifiers, action: Action = .none, configure: HeaderConfigurator? = nil)
		case cell(withIdentifier: TableViewCellReuseIdentifiers, configure: HeaderConfigurator? = nil)
	}
	
	typealias Footer = Header
	
	enum Cell {
		// swiftlint:disable:next nesting
		typealias CellConfigurator = (_ cell: UITableViewCell, _ indexPath: IndexPath) -> Void
		
		case bold(text: String)
		case semibold(text: String)
		case regular(text: String)
		case icon(action: Action = .none, text: String, image: UIImage?, backgroundColor: UIColor, tintColor: UIColor)
		case identifier(_ identifier: TableViewCellReuseIdentifiers, action: Action = .none, configure: CellConfigurator? = nil)
		
		var action: Action {
			switch self {
			case let .icon(action, _, _, _, _):
				return action
			case let .identifier(_, action, _):
				return action
			default:
				return .none
			}
		}
	}
	
	enum Action {
		case none
		case call(number: String)
		case open(url: URL?)
		case perform(segue: SegueIdentifiers)
		case execute(block: (_ viewController: UIViewController) -> Void)
	}
}
