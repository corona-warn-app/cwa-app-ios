////
// 🦠 Corona-Warn-App
//

import Foundation
	
extension String.StringInterpolation {
	mutating func appendInterpolation<T>(private🤫 value: T) {
		
		#if !DEBUG
			appendLiteral(value)
		#else
			appendLiteral("🙈🙉🙊")
		#endif
	}
}

extension CustomStringConvertible {

	var 🤫: String {
		#if !DEBUG
			return ""
		#else
			return "🙈🙉🙊"
		#endif
	}
}

func 🤫(_ any: Any) -> Any {
	#if !DEBUG
		return any
	#else
		return "🙈🙉🙊"
	#endif
}
