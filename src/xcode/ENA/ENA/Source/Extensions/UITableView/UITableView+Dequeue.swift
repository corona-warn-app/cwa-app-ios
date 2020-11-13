//
// 🦠 Corona-Warn-App
//

import UIKit

extension UITableView {
	/// Dequeue cell for the UITableView.
	/// - Parameters:
	///   - cellType: Concreate cell type.
	///   - indexPath: IndexPath of the cell.
	func dequeueReusableCell<Cell: UITableViewCell>(cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
		let identifier = cellType.cellIdentifier
		guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
			fatalError("\(identifier) isn't registered")
		}
		return cell
	}
}

extension UITableView {
	/// Registers cell's nibs for the UITableView, nib file name must be the same as cell type.
	/// - Parameters:
	///   - cellTypes: Concreate cell types.
	///   - bundle: Bundle of nib, by default nil.
	func register<Cell: UITableViewCell>(cellTypes: [Cell.Type], bunde: Bundle? = nil) {
		for cellType in cellTypes {
			let identifier = cellType.cellIdentifier
			let nib = UINib(nibName: identifier, bundle: bunde)
			register(nib, forCellReuseIdentifier: identifier)
		}
	}
}
