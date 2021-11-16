//
// 🦠 Corona-Warn-App
//

import Foundation

public extension String {
    func dropPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {
            return self
        }
        return String(dropFirst(prefix.count))
    }
}
