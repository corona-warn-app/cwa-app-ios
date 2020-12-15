//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
	private static let semanticVersionComponentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.generatesDecimalNumbers = false
		formatter.allowsFloats = false
		return formatter
	}()

	var semanticVersion: SAP_Internal_V2_SemanticVersion? {
		let versions: [UInt32] = components(separatedBy: ".")
			.compactMap { type(of: self).semanticVersionComponentFormatter.number(from: $0)?.intValue }
			.map(UInt32.init)

		guard versions.count == 3 else {
			return nil
		}

		return SAP_Internal_V2_SemanticVersion.with {
			$0.major = versions[0]
			$0.minor = versions[1]
			$0.patch = versions[2]
		}
	}
}
