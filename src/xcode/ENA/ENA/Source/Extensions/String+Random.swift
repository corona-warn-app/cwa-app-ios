//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
	/// This method generates a random string containing the lowercase english alphabet letters a-z,
	/// given a specific size.
	public static func getRandomString(of size: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyz"
		var rand = ""
		for _ in 0..<size {
			rand += "\(letters.randomElement() ?? "a")"
		}
		return rand
	}
}
