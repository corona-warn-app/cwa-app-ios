////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

protocol DMConfigureAbleCell {

	func configure<T>(cellViewModel: T)

	static var reuseIdentifier: String { get }
}

extension DMConfigureAbleCell {

	static var reuseIdentifier: String {
		String(describing: self)
	}

}
#endif
