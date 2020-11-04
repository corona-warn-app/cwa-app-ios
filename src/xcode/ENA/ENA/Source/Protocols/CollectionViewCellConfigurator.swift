import UIKit

protocol CollectionViewCellConfiguratorAny: AnyObject {
	var viewAnyType: UICollectionViewCell.Type { get }

	func configureAny(cell: UICollectionViewCell)

	var hashValue: AnyHashable { get }
}

protocol CollectionViewCellConfigurator: CollectionViewCellConfiguratorAny, Hashable {
	associatedtype CellType: UICollectionViewCell
	func configure(cell: CellType)
}

extension CollectionViewCellConfigurator {
	var viewAnyType: UICollectionViewCell.Type {
		CellType.self
	}

	func configureAny(cell: UICollectionViewCell) {
		if let cell = cell as? CellType {
			configure(cell: cell)
		} else {
			let error = "\(cell) isn't conformed CellType"
			Log.error(error, log: .ui)
			fatalError(error)
		}
	}

	var hashValue: AnyHashable {
		self
	}
}
