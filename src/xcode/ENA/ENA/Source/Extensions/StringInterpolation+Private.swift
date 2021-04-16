////
// 🦠 Corona-Warn-App
//

import Foundation
	
extension String.StringInterpolation {
	mutating func appendInterpolation<T>(private value: T) {
		
		#if DEBUG
			appendLiteral(String(describing: value))
		#else
			appendLiteral("🙈🙉🙊")
		#endif
	}
}
