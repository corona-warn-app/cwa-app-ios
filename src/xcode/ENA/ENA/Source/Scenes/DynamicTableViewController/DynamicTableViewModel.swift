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
	let content: [Section]
	
	
	init(_ content: [Section]) {
		self.content = content
	}
	
	
	struct Section {
		let header: Header?
		let separators: Bool
		let cells: [Cell]
		
		private init(header: Header?, separators: Bool = true, cells: [Cell]) {
			self.header = header
			self.separators = separators
			self.cells = cells
		}
		
		static func section(header: Header?, separators: Bool = true, cells: [Cell]) -> Section {
			return .init(header: header, separators: separators, cells: cells)
		}
	}
	
	enum Header {
		case none
		case text(_ text: String)
		case image(_ image: UIImage?, height: CGFloat = 250)
		case view(_ view: UIView)
	}
	
	enum Cell {
		case bold(text: String)
		case semibold(text: String)
		case regular(text: String)
		
		var action: Action? {
			switch self {
			default:
				return nil
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
