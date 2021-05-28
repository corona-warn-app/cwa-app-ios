////
// 🦠 Corona-Warn-App
//

import Foundation
	
extension String.StringInterpolation {
	/// Use this method when logging sensitive data. This ensures, that the logged information is censored in release builds, but not in debug build, which is needed for us devs and the testers.
	/// - Parameters:
	///   - private: The sensitive data to be replaced in release builds with '🙈🙉🙊'.
	///   - public: Additional explination text what should be logged as data but is censored.
	mutating func appendInterpolation<T>(private value: T, public text: String = "") {
		#if !RELEASE
			// Community, Debug, TestFlight, AdHoc
			appendLiteral(String(describing: value))
		#else
			// Release
			text.isEmpty ? appendLiteral("🙈🙉🙊") : appendLiteral("🙈🙉🙊. (Censoring cause: " + text + ")")
		#endif
	}
}
