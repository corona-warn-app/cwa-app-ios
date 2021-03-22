////
// 🦠 Corona-Warn-App
//

import Foundation

protocol ConfigureableCell: ReuseIdentifierProviding {

	func configure<T>(cellViewModel: T)

}

protocol ReuseIdentifierProviding {

	static var reuseIdentifier: String { get }

}

extension ReuseIdentifierProviding {

	static var reuseIdentifier: String {
		String(describing: self)
	}

}
