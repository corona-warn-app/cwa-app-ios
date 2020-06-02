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

class DynamicTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var dynamicTableViewModel = DynamicTableViewModel([])

	@IBOutlet private(set) var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		if tableView == nil { tableView = view as? UITableView }

		tableView.register(DynamicTableViewHeaderImageView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.header.rawValue)
		tableView.register(DynamicTableViewHeaderSeparatorView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.separator.rawValue)

		tableView.register(DynamicTypeTableViewCell.Bold.self, forCellReuseIdentifier: CellReuseIdentifier.bold.rawValue)
		tableView.register(DynamicTypeTableViewCell.Semibold.self, forCellReuseIdentifier: CellReuseIdentifier.semibold.rawValue)
		tableView.register(DynamicTypeTableViewCell.Regular.self, forCellReuseIdentifier: CellReuseIdentifier.regular.rawValue)
		tableView.register(DynamicTypeTableViewCell.BigBold.self, forCellReuseIdentifier: CellReuseIdentifier.bigBold.rawValue)
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
		case bigBold = "bigBoldCell"
		case bold = "boldCell"
		case semibold = "semiboldCell"
		case regular = "regularCell"
		case icon = "iconCell"
	}
}

extension DynamicCell {
	var cellReuseIdentifier: TableViewCellReuseIdentifiers {
		switch self {
		case .bigBold:
			return DynamicTableViewController.CellReuseIdentifier.bigBold
		case .bold:
			return DynamicTableViewController.CellReuseIdentifier.bold
		case .semibold:
			return DynamicTableViewController.CellReuseIdentifier.semibold
		case .regular:
			return DynamicTableViewController.CellReuseIdentifier.regular
		case .icon:
			return DynamicTableViewController.CellReuseIdentifier.icon
		case let .identifier(identifier, _, _, _):
			return identifier
		}
	}

	func configure(cell: UITableViewCell, at indexPath: IndexPath, for viewController: DynamicTableViewController) {
		switch self {
		case let .bigBold(text):
			cell.textLabel?.text = text

		case let .bold(text):
			cell.textLabel?.text = text

		case let .semibold(text):
			cell.textLabel?.text = text

		case let .regular(text):
			cell.textLabel?.text = text

		case let .icon(_, configuration):
			(cell as? DynamicTableViewIconCell)?.configure(configuration)

		case let .identifier(_, _, _, configure):
			configure?(viewController, cell, indexPath)
		}
	}
}

extension DynamicTableViewController {
	private func tableView(_: UITableView, titleForHeaderFooter headerFooter: DynamicHeader, inSection _: Int) -> String? {
		switch headerFooter {
		case let .text(text):
			return text
		default:
			return nil
		}
	}

	private func tableView(_: UITableView, heightForHeaderFooter headerFooter: DynamicHeader, inSection _: Int) -> CGFloat {
		switch headerFooter {
		case .none:
			return .leastNonzeroMagnitude
		case .blank:
			return UITableView.automaticDimension
		case let .space(height, _):
			return height
		default:
			return UITableView.automaticDimension
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	private func tableView(_ tableView: UITableView, viewForHeaderFooter headerFooter: DynamicHeader, inSection section: Int) -> UIView? {
		switch headerFooter {
		case let .space(_, color):
			if let color = color {
				let view = UIView()
				view.backgroundColor = color
				return view
			} else {
				return nil
			}

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

		case let .custom(block):
			return block(self)

		default:
			return nil
		}
	}

	private func execute(action: DynamicAction) {
		switch action {
		case let .open(url):
			if let url = url { UIApplication.shared.open(url) }

		case let .call(number):
			if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }

		case let .perform(segueIdentifier):
			performSegue(withIdentifier: segueIdentifier, sender: nil)

		case let .execute(block):
			block(self)

		case .none:
			break
		}
	}
}

extension DynamicTableViewController {
	func numberOfSections(in _: UITableView) -> Int {
		dynamicTableViewModel.numberOfSection
	}

	func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		if dynamicTableViewModel.section(section).isHidden(for: self) {
			return 1
		} else {
			return dynamicTableViewModel.numberOfRows(inSection: section, for: self)
		}
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let content = dynamicTableViewModel.section(section)
		if content.isHidden(for: self) {
			return nil
		} else {
			return self.tableView(tableView, titleForHeaderFooter: content.header, inSection: section)
		}
	}

	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let content = dynamicTableViewModel.section(section)
		if content.isHidden(for: self) {
			return nil
		} else {
			return self.tableView(tableView, titleForHeaderFooter: content.footer, inSection: section)
		}
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let content = dynamicTableViewModel.section(section)
		if content.isHidden(for: self) {
			return .leastNonzeroMagnitude
		} else {
			return self.tableView(tableView, heightForHeaderFooter: content.header, inSection: section)
		}
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let content = dynamicTableViewModel.section(section)
		if content.isHidden(for: self) {
			return .leastNonzeroMagnitude
		} else {
			return self.tableView(tableView, heightForHeaderFooter: content.footer, inSection: section)
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let content = dynamicTableViewModel.section(section)
		if content.isHidden(for: self) {
			return nil
		} else {
			return self.tableView(tableView, viewForHeaderFooter: content.header, inSection: section)
		}
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let content = dynamicTableViewModel.section(section)
		if content.isHidden(for: self) {
			return nil
		} else {
			return self.tableView(tableView, viewForHeaderFooter: content.footer, inSection: section)
		}
	}

	func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if dynamicTableViewModel.section(at: indexPath).isHidden(for: self) {
			return .leastNonzeroMagnitude
		} else {
			return UITableView.automaticDimension
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if dynamicTableViewModel.section(at: indexPath).isHidden(for: self) {
			return UITableViewCell()
		}

		let section = dynamicTableViewModel.section(at: indexPath)
		let content = dynamicTableViewModel.cell(at: indexPath)

		let cell = tableView.dequeueReusableCell(withIdentifier: content.cellReuseIdentifier, for: indexPath)

		content.configure(cell: cell, at: indexPath, for: self)

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

	func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let content = dynamicTableViewModel.cell(at: indexPath)
		execute(action: content.accessoryAction)
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
			contentView.viewWithTag(100_001)?.removeFromSuperview()
			contentView.viewWithTag(100_002)?.removeFromSuperview()
			contentView.viewWithTag(100_003)?.removeFromSuperview()
			return
		}

		let separator = UIView(frame: bounds)
		contentView.addSubview(separator)
		separator.backgroundColor = .preferredColor(for: .separator)
		separator.translatesAutoresizingMaskIntoConstraints = false
		separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

		switch location {
		case .top:
			separator.tag = 100_001
			separator.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
			separator.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		case .bottom:
			separator.tag = 100_002
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
			separator.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		case .inset:
			separator.tag = 100_002
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
			separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
		default:
			break
		}
	}
}
