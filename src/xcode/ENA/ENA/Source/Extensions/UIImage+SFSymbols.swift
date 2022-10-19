//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIImage {
	enum SFSymbol: String {
		@available(iOS 15, *)
		case rectanglePortraitAndArrowRight = "rectangle.portrait.and.arrow.right"
	}
	
	/// Create a image based on the Apple SF Symbols library.
	///
	/// - Parameters:
	/// 	- sfSymbol: SF Symbol type, dependent from SF Symbol Version.
	/// 	- withConfiguration: Give some symbol configurations like symbol weight
	/// 	- withTintColor: If you want to colorize your image
	@available(iOS 13.0, *)
	static func sfSymbol(
		_ sfSymbol: SFSymbol,
		withConfiguration configuration: UIImage.SymbolConfiguration? = nil,
		withTintColor tintColor: UIColor
	) -> UIImage? {
		UIImage(
			systemName: sfSymbol.rawValue,
			withConfiguration: configuration
		)?.withTintColor(
			tintColor,
			renderingMode: .alwaysOriginal
		)
	}
}
