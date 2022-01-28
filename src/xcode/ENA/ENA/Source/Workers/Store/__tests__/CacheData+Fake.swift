//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension CacheData {

	static func fake(
		data: Data = Data(),
		eTag: String = "",
		date: Date = Date()
	) -> CacheData {
		return CacheData(
			data: data,
			eTag: eTag,
			date: date
		)
	}

}
