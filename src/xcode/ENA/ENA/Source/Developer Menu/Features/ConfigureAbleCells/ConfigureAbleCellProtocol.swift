////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

protocol ConfigureAbleCell {

	func configure<T>(cellViewModel: T)

	static var reuseIdentifier: String { get }
}

extension ConfigureAbleCell {

	static var reuseIdentifier: String {
		String(describing: self)
	}

}
#endif
