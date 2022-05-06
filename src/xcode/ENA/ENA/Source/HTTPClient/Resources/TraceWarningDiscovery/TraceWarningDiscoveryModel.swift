////
// 🦠 Corona-Warn-App
//

import Foundation

@available(*, deprecated)
struct TraceWarningDiscoveryModel: Decodable, MetaDataProviding {

	// MARK: - init

	init(oldest: Int, latest: Int, eTag: String?) {
		self.oldest = oldest
		self.latest = latest
		self.metaData = MetaData()
		// store optional eTag
		if let eTag = eTag {
			metaData.headers.updateValue(eTag, forKey: "ETag")
		}
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

	var eTag: String? {
		metaData.headers.value(caseInsensitiveKey: "ETag")
	}

	var availablePackagesOnCDN: [Int] {
		return latest < oldest ? [] : Array(oldest...latest)
	}

}
