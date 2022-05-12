////
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceWarningDiscoveryModel: Decodable, MetaDataProviding {

	// MARK: - init

	init(
		oldest: Int,
		latest: Int
	) {
		self.oldest = oldest
		self.latest = latest
		self.metaData = MetaData()
	}

	// MARK: - Protocol Decodable

	enum CodingKeys: String, CodingKey {
		case oldest
		case latest
	}

	init(from decoder: Decoder) throws {
		metaData = MetaData()

		let container = try decoder.container(keyedBy: CodingKeys.self)
		let _oldest = try container.decodeIfPresent(Int.self, forKey: .oldest)
		let _latest = try container.decodeIfPresent(Int.self, forKey: .latest)

		guard let _oldest = _oldest,
			  let _latest = _latest else {
			oldest = 0
			latest = -1
			return
		}
		oldest = _oldest
		latest = _latest
	}

	// MARK: Protocol: MetaDataProviding

	var metaData: MetaData

	// MARK: - Internal

	let oldest: Int
	let latest: Int

	var availablePackagesOnCDN: [Int] {
		return latest < oldest ? [] : Array(oldest...latest)
	}

}
