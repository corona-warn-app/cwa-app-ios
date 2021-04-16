////
// 🦠 Corona-Warn-App
//

import Foundation
	
/// If we prefix the content of the string interpolation with 'private', the content will be replaced by '🙈🙉🙊' to ensure no private infomation is logged.
extension String.StringInterpolation {
	mutating func appendInterpolation<T>(private value: T) {
		
		#if DEBUG
			appendLiteral(String(describing: value))
		#else
			appendLiteral("🙈🙉🙊")
		#endif
	}
}
