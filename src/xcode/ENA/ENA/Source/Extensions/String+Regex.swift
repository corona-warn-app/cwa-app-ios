//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
    public func check(regex: String) -> Bool {
       
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let result = regex.firstMatch(in: self, range: .init(location: 0, length: self.count))
            return result != nil
        } catch {
            return false
        }
    }
}
