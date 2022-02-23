//
// 🦠 Corona-Warn-App
//

/// possible policies to use caching in a resource
enum CacheUsePolicy: Equatable, Hashable {
	case noNetwork
	case statusCode(Int)
	case loadOnlyOnceADay
}

extension Set where Element == CacheUsePolicy {

	func appendingStatusCodes(_ range: ClosedRange<Int>) -> Set<CacheUsePolicy> {
		var rangeSet = Set<CacheUsePolicy>()
		range.forEach { code in
			rangeSet.insert(.statusCode(code))
		}
		return rangeSet.union(self)
	}
}
