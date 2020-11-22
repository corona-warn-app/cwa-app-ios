//
// 🦠 Corona-Warn-App
//

import UIKit

extension UICollectionView {
	/// Dequeue cell for the UICollectionView.
	/// - Parameters:
	///   - cellType: Concreate cell type.
	///   - indexPath: IndexPath of the cell.
	func dequeueReusableCell<Cell: UICollectionViewCell>(cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
		let identifier = cellType.cellIdentifier
		guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
			fatalError("\(identifier) isn't registered")
		}
		return cell
	}

	/// Dequeue reusable view for the UICollectionView.
	/// - Parameters:
	///   - reusableViewType: Concreate reusable view type.
	///   - kind: The kind of reusable view to dequeue.
	///   - indexPath: IndexPath of the cell.
	func dequeueReusableSupplementaryView<ReusableView: UICollectionReusableView>(reusableViewType: ReusableView.Type, kind: String, for indexPath: IndexPath) -> ReusableView {
		let identifier = reusableViewType.reusableViewIdentifier
		guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? ReusableView else { fatalError("\(identifier) isn't registered") }
		return view
	}
}

extension UICollectionView {
	/// Registers cell's nibs for the UICollectionView, nib file name must be the same as cell type.
	/// - Parameters:
	///   - cellTypes: Concreate cell types.
	///   - bundle: Bundle of nib, by default nil.
	func register<Cell: UICollectionViewCell>(cellTypes: [Cell.Type], bunde: Bundle? = nil) {
		for cellType in cellTypes {
			let identifier = cellType.cellIdentifier
			let nib = UINib(nibName: identifier, bundle: bunde)
			register(nib, forCellWithReuseIdentifier: identifier)
		}
	}

	/// Registers reusable view's nibs for the UICollectionView, nib file name must be the same as reusable view type.
	/// - Parameters:
	///   - reusableViews: Concreate reusable view types.
	///   - kind: The kind of reusable view to create.
	///   - bundle: Bundle of nib, by default nil.
	func register<ReusableView: UICollectionReusableView>(reusableViews: [ReusableView.Type], kind: String, bunde: Bundle? = nil) {
		for reusableView in reusableViews {
			let identifier = reusableView.reusableViewIdentifier
			let nib = UINib(nibName: identifier, bundle: bunde)
			register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
		}
	}
}
