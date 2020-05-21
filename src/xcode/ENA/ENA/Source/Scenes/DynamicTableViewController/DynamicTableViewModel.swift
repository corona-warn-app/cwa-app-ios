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
	let primaryAction: Action
	let content: [Section]
	
	
	enum Header {
		case none
		case text(_ text: String)
		case image(_ image: UIImage?)
		case view(_ view: UIView)
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
	
	enum Cell {
		case semibold(text: String)
		case regular(text: String)
		case icon(action: Action? = nil, text: String, image: UIImage?, backgroundColor: UIColor, tintColor: UIColor)
		case phone(action: Action? = nil, text: String)
		
		var action: Action? {
			switch self {
			case let .icon(action, _, _, _, _):
				return action
			case let .phone(action, _):
				return action
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
		case custom((_ viewController: UIViewController) -> Void)
	}
}
