////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

protocol ConfigureableCell {

	func configure<T>(cellViewModel: T)

	static var reuseIdentifier: String { get }
}

extension ConfigureableCell {

	static var reuseIdentifier: String {
		String(describing: self)
	}

}
#endif
