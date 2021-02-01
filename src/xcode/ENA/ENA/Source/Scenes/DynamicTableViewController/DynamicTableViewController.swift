//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var dynamicTableViewModel = DynamicTableViewModel([])

	@IBOutlet private(set) lazy var tableView: UITableView! = self.view as? UITableView

	override func loadView() {
		if nil != nibName {
			super.loadView()
		} else {
			view = UITableView(frame: .zero, style: .grouped)
		}

		if nil == tableView {
			fatalError("\(String(describing: Self.self)) must be provided with a \(String(describing: UITableView.self)).")
		}

		tableView.delegate = self
		tableView.dataSource = self

		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
		tableView.sectionHeaderHeight = UITableView.automaticDimension
		tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
		tableView.sectionFooterHeight = UITableView.automaticDimension
		tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.register(DynamicTableViewHeaderImageView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.header.rawValue)
		tableView.register(DynamicTableViewHeaderSeparatorView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterReuseIdentifier.separator.rawValue)

		tableView.register(DynamicTypeTableViewCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.dynamicTypeLabel.rawValue)
		tableView.register(DynamicTableViewTextViewCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.dynamicTypeTextView.rawValue)
		tableView.register(DynamicTableViewSpaceCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.space.rawValue)
		tableView.register(DynamicTableViewIconCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.icon.rawValue)
		tableView.register(DynamicTableViewBulletPointCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.bulletPoint.rawValue)
	}
}

extension DynamicTableViewController {
	enum HeaderFooterReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case header = "headerView"
		case separator = "separatorView"
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

		case let .image(image, accessibilityLabel: label, accessibilityIdentifier: accessibilityIdentifier, height, accessibilityTraits):
			let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterReuseIdentifier.header.rawValue) as? DynamicTableViewHeaderImageView
			view?.imageView?.image = image
			if let label = label {
				view?.imageView?.isAccessibilityElement = true
				view?.imageView?.accessibilityLabel = label
			}
			view?.imageView?.accessibilityIdentifier = accessibilityIdentifier
			view?.imageView?.accessibilityTraits = accessibilityTraits
			if let height = height {
				view?.height = height
			} else if let imageWidth = image?.size.width,
			   let imageHeight = image?.size.height {
				// view.bounds.size.width will not be set at that point
				// tableviews always use full screen, so it might work to use screen size here
				let cellWidth = UIScreen.main.bounds.size.width
				let ratio = imageHeight / imageWidth
				view?.height = cellWidth * ratio
			} else {
				view?.height = 250.0
			}
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
			Log.error("Missing dynamic header type: \(String(describing: headerFooter))")
			return nil
		}
	}

	final func execute(action: DynamicAction, cell: UITableViewCell? = nil) {
		switch action {
		case let .open(url):
			if let url = url { LinkHelper.openLink(withUrl: url, from: self) }

		case let .call(number):
			if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }

		case let .execute(block):
			block(self, cell)

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

		cell.removeSeparators()

		// no separators for spacers please
		if section.separators != .none, cell is DynamicTableViewSpaceCell == false {
			let isFirst = indexPath.row == 0
			let isLast = indexPath.row == section.cells.count - 1

			if isFirst && section.separators == .all { cell.addSeparator(.top) }
			if isLast && section.separators == .all { cell.addSeparator(.bottom) }
			if !isLast { cell.addSeparator(.inBetween) }
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let dynamicCell = dynamicTableViewModel.cell(at: indexPath)
		let cell = tableView.cellForRow(at: indexPath)
		execute(action: dynamicCell.action, cell: cell)
	}

	func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let dynamicCell = dynamicTableViewModel.cell(at: indexPath)
		guard let cell = tableView.cellForRow(at: indexPath) else { return }
		execute(action: dynamicCell.accessoryAction, cell: cell)
	}
}

private extension UITableViewCell {
	enum SeparatorLocation: Int {
		case top = 100_001
		case bottom = 100_002
		case inBetween = 100_003
	}

	func removeSeparators() {
		viewWithTag(SeparatorLocation.top.rawValue)?.removeFromSuperview()
		viewWithTag(SeparatorLocation.bottom.rawValue)?.removeFromSuperview()
		viewWithTag(SeparatorLocation.inBetween.rawValue)?.removeFromSuperview()
	}

	func addSeparator(_ location: SeparatorLocation) {
		let separator = UIView(frame: bounds)
		separator.backgroundColor = .enaColor(for: .hairline)
		separator.translatesAutoresizingMaskIntoConstraints = false

		addSubview(separator)
		NSLayoutConstraint.activate([
			separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
			separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
			separator.heightAnchor.constraint(equalToConstant: 1)
		])

		switch location {
		case .top:
			separator.tag = SeparatorLocation.top.rawValue
			separator.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		case .bottom:
			separator.tag = SeparatorLocation.bottom.rawValue
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		case .inBetween:
			separator.tag = SeparatorLocation.inBetween.rawValue
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		}
	}
}
