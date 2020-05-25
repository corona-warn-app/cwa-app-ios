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
	var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	@IBOutlet private(set) var tableView: UITableView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if nil == tableView { tableView = view as? UITableView }
		
		tableView.register(DynamicTableViewHeaderImageView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.header.rawValue)
		tableView.register(DynamicTableViewHeaderSeparatorView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.separator.rawValue)
		
		tableView.register(DynamicTypeTableViewCell.Bold.self, forCellReuseIdentifier: CellReuseIdentifier.bold.rawValue)
		tableView.register(DynamicTypeTableViewCell.Semibold.self, forCellReuseIdentifier: CellReuseIdentifier.semibold.rawValue)
		tableView.register(DynamicTypeTableViewCell.Regular.self, forCellReuseIdentifier: CellReuseIdentifier.regular.rawValue)
		tableView.register(UINib(nibName: String(describing: DynamicTableViewIconCell.self), bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.icon.rawValue)
	}
}


extension DynamicTableViewController {
	enum HeaderFooterReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case header = "headerView"
		case separator = "separatorView"
	}
}


extension DynamicTableViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case bold = "boldCell"
		case semibold = "semiboldCell"
		case regular = "regularCell"
		case icon = "iconCell"
	}
}


extension DynamicTableViewModel.Cell {
	var cellReuseIdentifier: TableViewCellReuseIdentifiers {
		switch self {
		case .bold:
			return DynamicTableViewController.CellReuseIdentifier.bold
		case .semibold:
			return DynamicTableViewController.CellReuseIdentifier.semibold
		case .regular:
			return DynamicTableViewController.CellReuseIdentifier.regular
		case .icon:
			return DynamicTableViewController.CellReuseIdentifier.icon
		case let .identifier(identifier, _, _):
			return identifier
		}
	}
	
	
	func configure(cell: UITableViewCell, at indexPath: IndexPath) {
		switch self {
		case let .bold(text):
			cell.textLabel?.text = text
			
		case let .semibold(text):
			cell.textLabel?.text = text
			
		case let .regular(text):
			cell.textLabel?.text = text
			
		case let .icon(_, text, image, backgroundColor, tintColor):
			(cell as? DynamicTableViewIconCell)?.configure(text: text, image: image, backgroundColor: backgroundColor, tintColor: tintColor)
			
		case let .identifier(_, _, configure):
			configure?(cell, indexPath)
		}
	}
}


extension DynamicTableViewController {
	private func tableView(_ tableView: UITableView, titleForHeaderFooter headerFooter: DynamicTableViewModel.Header, inSection section: Int) -> String? {
		switch headerFooter {
		case let .text(text):
			return text
		default:
			return nil
		}
	}
	
	
	private func tableView(_ tableView: UITableView, heightForHeaderFooter headerFooter: DynamicTableViewModel.Header, inSection section: Int) -> CGFloat {
		switch headerFooter {
		case .none:
			return 0
		case .blank:
			return UITableView.automaticDimension
		case let .space(height):
			return height
		default:
			return UITableView.automaticDimension
		}
	}
	
	
	private func tableView(_ tableView: UITableView, viewForHeaderFooter headerFooter: DynamicTableViewModel.Header, inSection section: Int) -> UIView? {
		switch headerFooter {
		case let .separator(color, height, insets):
			let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterReuseIdentifier.separator.rawValue) as? DynamicTableViewHeaderSeparatorView
			view?.color = color
			view?.height = height
			view?.layoutMargins = insets
			return view
			
		case let .image(image, height):
			let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterReuseIdentifier.header.rawValue) as? DynamicTableViewHeaderImageView
			view?.imageView?.image = image
			view?.height = height
			return view
			
		case let .view(view):
			return view
			
		case let .identifier(identifier, action, configure):
			let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
			if let view = view { configure?(view, section) }
			if let view = view as? DynamicTableViewHeaderFooterView {
				view.block = { self.execute(action: action) }
			}
			return view
			
		case let .cell(identifier, configure):
			let view = tableView.dequeueReusableCell(withIdentifier: identifier)
			if let view = view { configure?(view, section) }
			return view
		default:
			return nil
		}
	}
	
	
	private func execute(action: DynamicTableViewModel.Action) {
		switch action {
		case let .open(url):
			if let url = url { UIApplication.shared.open(url) }
			
		case let .call(number):
			if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
			
		case let .perform(segueIdentifier):
			self.performSegue(withIdentifier: segueIdentifier, sender: nil)
			
		case let .execute(block):
			block(self)
			
		case .none:
			break
		}
	}
}


extension DynamicTableViewController {
	func numberOfSections(in tableView: UITableView) -> Int {
		return dynamicTableViewModel.numberOfSection
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dynamicTableViewModel.numberOfRows(inSection: section)
	}
	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let content = dynamicTableViewModel.section(section)
		return self.tableView(tableView, titleForHeaderFooter: content.header, inSection: section)
	}
	
	
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let content = dynamicTableViewModel.section(section)
		return self.tableView(tableView, titleForHeaderFooter: content.footer, inSection: section)
	}

	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let content = dynamicTableViewModel.section(section)
		return self.tableView(tableView, heightForHeaderFooter: content.header, inSection: section)
	}
	
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let content = dynamicTableViewModel.section(section)
		return self.tableView(tableView, heightForHeaderFooter: content.footer, inSection: section)
	}
	
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let content = dynamicTableViewModel.section(section)
		return self.tableView(tableView, viewForHeaderFooter: content.header, inSection: section)
	}
	
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let content = dynamicTableViewModel.section(section)
		return self.tableView(tableView, viewForHeaderFooter: content.footer, inSection: section)
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = dynamicTableViewModel.section(at: indexPath)
		let content = dynamicTableViewModel.cell(at: indexPath)
		
		let cell = tableView.dequeueReusableCell(withIdentifier: content.cellReuseIdentifier, for: indexPath)
		
		content.configure(cell: cell, at: indexPath)
		
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
		let content = dynamicTableViewModel.cell(at: indexPath)
		execute(action: content.action)
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
