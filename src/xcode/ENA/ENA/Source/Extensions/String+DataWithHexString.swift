//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {

	func dataWithHexString() -> Data {
		var hex = self
		var data = Data()
		while !hex.isEmpty {
			let subIndex = hex.index(hex.startIndex, offsetBy: 2)
			let c = String(hex[..<subIndex])
			hex = String(hex[subIndex...])
			var ch: UInt32 = 0
			Scanner(string: c).scanHexInt32(&ch)
			var char = UInt8(ch)
			data.append(&char, count: 1)
		}

		return data
	}

}
