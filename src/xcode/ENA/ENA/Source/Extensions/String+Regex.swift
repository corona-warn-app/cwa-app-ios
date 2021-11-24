//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
    /// This method generates a random string containing the lowercase english alphabet letters a-z,
    /// given a specific size.
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
