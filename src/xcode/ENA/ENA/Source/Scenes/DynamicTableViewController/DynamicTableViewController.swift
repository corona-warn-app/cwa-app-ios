//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

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
		tableView.register(DynamicTableViewIconWithLinkTextCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.iconWithLinkText.rawValue)
		tableView.register(DynamicTableViewBulletPointCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.bulletPoint.rawValue)
		tableView.register(DynamicTableViewHeadlineWithImageCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.headlineWithImage.rawValue)
		tableView.register(DynamicTableViewDoubleLabelViewCell.self, forCellReuseIdentifier: DynamicCell.CellReuseIdentifier.doubleLabel.rawValue)

		setupKeyboardAvoidance()
	}

	private func setupKeyboardAvoidance() {
		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillShowNotification)
			.append(NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillChangeFrameNotification))
			.sink { [weak self] notification in

				guard let self = self,
					  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
					  let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
					  let animationCurveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
					  let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue) else {
					return
				}

				var targetRect: CGRect?
				if let currentResponder = self.view.firstResponder as? UIView {
					let rect = currentResponder.convert(currentResponder.bounds, to: self.view)
					if keyboardFrame.intersects(rect) {
						targetRect = rect
					}
				}

				let animator = UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) { [weak self] in
					self?.tableView.scrollIndicatorInsets.bottom = keyboardFrame.height
					self?.tableView.contentInset.bottom = keyboardFrame.height
					if let targetRect = targetRect {
						self?.tableView.scrollRectToVisible(targetRect, animated: false)
					}
				}
				animator.startAnimation()
			}
			.store(in: &keyboardSubscriptions)

		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillHideNotification)
			.sink { [weak self] notification in

				guard let self = self,
					  let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
					  let animationCurveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
					  let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue) else {
					return
				}

				let animator = UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) { [weak self] in
					self?.tableView.scrollIndicatorInsets.bottom = 0
					self?.tableView.contentInset.bottom = 0
				}
				animator.startAnimation()
			}
			.store(in: &keyboardSubscriptions)
	}

	// MARK: - Private

	private var keyboardSubscriptions = Set<AnyCancellable>()

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

		case let .image(image, title, accessibilityLabel: label, accessibilityIdentifier: accessibilityIdentifier, height, accessibilityTraits):
			let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterReuseIdentifier.header.rawValue) as? DynamicTableViewHeaderImageView
			view?.imageView?.image = image
			view?.imageView?.isAccessibilityElement = label != nil
			view?.imageView?.accessibilityLabel = label
			view?.imageView?.accessibilityIdentifier = accessibilityIdentifier
			view?.imageView?.accessibilityTraits = accessibilityTraits

			// optional title that will be shown over the image and scroll with it.
			view?.titleLabel.isAccessibilityElement = title != nil
			view?.titleLabel.accessibilityLabel = title
			view?.titleLabel.accessibilityTraits = .header
			view?.title = title

			view?.accessibilityElements = [view?.titleLabel as Any, view?.imageView as Any]

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
			if let url = url { LinkHelper.open(url: url) }

		case let .call(number):
			LinkHelper.open(urlString: "tel://\(number)")

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
		
		cell.drawBackground(section: section, at: indexPath)
		
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
	
	func removeSeparators() {
		viewWithTag(CellSeparatorLineLocation.top.rawValue)?.removeFromSuperview()
		viewWithTag(CellSeparatorLineLocation.bottom.rawValue)?.removeFromSuperview()
		viewWithTag(CellSeparatorLineLocation.inBetween.rawValue)?.removeFromSuperview()
	}

	func addSeparator(_ location: CellSeparatorLineLocation) {
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
			separator.tag = CellSeparatorLineLocation.top.rawValue
			separator.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		case .bottom:
			separator.tag = CellSeparatorLineLocation.bottom.rawValue
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		case .inBetween:
			separator.tag = CellSeparatorLineLocation.inBetween.rawValue
			separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		}
	}
}

/// Stuff to draw a background to the cell, depending on the position of the cell in the section it gets rounded corners.

private extension UITableViewCell {
	
	func drawBackground(
		section: DynamicSection,
		at indexPath: IndexPath
	) {
		self.removeBackground()
		
		switch section.background {
		case .none:
			break
		case .greyBoxed:
			
			// Give the root view in the content view of the cell some insets to the border. If we change the contentView's constraints, it would not affect the subviews.
			if let subview = self.subviews.first?.subviews.first {
				subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
				subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
				
				// If the subview in the cell is a textView, we need some more extra space for the bottom.
				if let textview = subview as? UITextView {
					textview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
				}
			}
			
			let isFirst = indexPath.row == 0
			let isLast = indexPath.row == section.cells.count - 1
			
			if isFirst {
				self.addBackground(.top)
			} else if isLast {
				self.addBackground(.bottom)
			} else {
				self.addBackground(.inBetween)
			}
		}
	}
	
	private func removeBackground() {
		viewWithTag(CellBackgroundLocation.top.rawValue)?.removeFromSuperview()
		viewWithTag(CellBackgroundLocation.bottom.rawValue)?.removeFromSuperview()
		viewWithTag(CellBackgroundLocation.inBetween.rawValue)?.removeFromSuperview()
	}

	private func addBackground(_ location: CellBackgroundLocation) {
		let coloredBackground = UIView(frame: bounds)
		coloredBackground.backgroundColor = .enaColor(for: .cellBackground3)
		coloredBackground.translatesAutoresizingMaskIntoConstraints = false

		switch location {
		case .top:
			coloredBackground.tag = CellBackgroundLocation.top.rawValue
			coloredBackground.clipsToBounds = true
			coloredBackground.layer.cornerRadius = 10
			coloredBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		case .bottom:
			coloredBackground.tag = CellBackgroundLocation.bottom.rawValue
			coloredBackground.clipsToBounds = true
			coloredBackground.layer.cornerRadius = 10
			coloredBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		case .inBetween:
			coloredBackground.tag = CellBackgroundLocation.inBetween.rawValue
		}

		
		addSubview(coloredBackground)
		sendSubviewToBack(coloredBackground)
		NSLayoutConstraint.activate([
			coloredBackground.topAnchor.constraint(equalTo: topAnchor),
			coloredBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
			coloredBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
			coloredBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
}
