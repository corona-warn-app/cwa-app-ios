import Foundation

extension NSObject {
	static func stringName() -> String {
		String(describing: self)
	}
}
