////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

protocol DMConfigureableCell {

	func configure<T>(cellViewModel: T)

	static var reuseIdentifier: String { get }
}

extension DMConfigureableCell {

	static var reuseIdentifier: String {
		String(describing: self)
	}

}
#endif
