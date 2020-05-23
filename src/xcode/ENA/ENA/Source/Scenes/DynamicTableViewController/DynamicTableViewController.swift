//
//  DynamicTableViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class DynamicTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var model: DynamicTableViewModel = DynamicTableViewModel([])
	
	var tableView: UITableView! { self.view as? UITableView }
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(DynamicTableHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.header.rawValue)
		tableView.register(DynamicTypeTableViewCell.Bold.self, forCellReuseIdentifier: CellReuseIdentifier.bold.rawValue)
		tableView.register(DynamicTypeTableViewCell.Semibold.self, forCellReuseIdentifier: CellReuseIdentifier.semibold.rawValue)
		tableView.register(DynamicTypeTableViewCell.Regular.self, forCellReuseIdentifier: CellReuseIdentifier.regular.rawValue)
	}
}


extension DynamicTableViewController {
	enum Section: Int, TableViewSections, CaseIterable {
		case content
	}
}


extension DynamicTableViewController {
	enum HeaderFooterReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case header = "headerView"
	}
}


extension DynamicTableViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case bold = "boldCell"
		case semibold = "semiboldCell"
		case regular = "regularCell"
	}
}


private extension DynamicTableViewModel.Cell {
	var cellType: DynamicTableViewController.CellReuseIdentifier {
		switch self {
		case .bold:
			return .bold
		case .semibold:
			return .semibold
		case .regular:
			return .regular
		}
	}
	
	func configure(cell: UITableViewCell) {
		switch self {
		case let .bold(text):
			cell.textLabel?.text = text
			
		case let .semibold(text):
			cell.textLabel?.text = text
			
		case let .regular(text):
			cell.textLabel?.text = text
		}
	}
}


extension DynamicTableViewController {
	func numberOfSections(in tableView: UITableView) -> Int {
		return model.content.count
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.content[section].cells.count
	}
	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let content = model.content[section]
		
		switch content.header {
		case let .text(text):
			return text
		default:
			return nil
		}
	}
	
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let content = model.content[section]
		
		switch content.header {
		case let .view(view):
			return view
		case let .image(image, height):
			let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterReuseIdentifier.header.rawValue) as? DynamicTableHeaderView
			view?.imageView?.image = image
			view?.height = height
			return view
		default:
			return nil
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = model.content[indexPath.section]
		let content = section.cells[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: content.cellType, for: indexPath)
		
		content.configure(cell: cell)
		
		if section.separators {
			let isFirst = indexPath.row == 0
			let isLast = indexPath.row == section.cells.count - 1
			
			if isFirst { cell.addSeparator(.top) }
			if isLast { cell.addSeparator(.bottom) }
			if !isLast { cell.addSeparator(.inset) }
		} else {
			cell.addSeparator(.clear)
		}
		
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let content = model.content[indexPath.section].cells[indexPath.row]
		
		switch content.action {
		case let .open(url):
			if let url = url { UIApplication.shared.open(url) }
		case let .call(number):
			if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
		case let .perform(segueIdentifier):
			self.performSegue(withIdentifier: segueIdentifier, sender: nil)
		case let .execute(block):
			block(self)
		default:
			break
		}
	}
}


private extension UITableViewCell {
	enum SeparatorLocation {
		case top
		case bottom
		case inset
		case clear
	}
	
	
	func addSeparator(_ location: SeparatorLocation) {
		if location == .clear {
			contentView.viewWithTag(100001)?.removeFromSuperview()
			contentView.viewWithTag(100002)?.removeFromSuperview()
			contentView.viewWithTag(100003)?.removeFromSuperview()
			return
		}
		
		let separator = UIView(frame: self.bounds)
		contentView.addSubview(separator)
		separator.backgroundColor = .preferredColor(for: .separator)
		separator.translatesAutoresizingMaskIntoConstraints = false
		separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		switch location {
		case .top:
			separator.tag = 100001
			separator.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
			separator.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		case .bottom:
			separator.tag = 100002
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
			separator.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		case .inset:
			separator.tag = 100002
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
			separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
		default:
			break
		}
	}
}
