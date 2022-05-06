////
// 🦠 Corona-Warn-App
//

import Foundation

@available(*, deprecated)
struct TraceWarningDiscoveryModel: Decodable, MetaDataProviding {

	// MARK: - init

	init(oldest: Int, latest: Int) {
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
		let container = try decoder.container(keyedBy: CodingKeys.self)
		oldest = try container.decode(Int.self, forKey: .oldest)
		latest = try container.decode(Int.self, forKey: .latest)
		metaData = MetaData()
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
