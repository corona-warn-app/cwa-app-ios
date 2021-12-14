//
// 🦠 Corona-Warn-App
//

/// type to handle caching log per resource
enum CachingType: Equatable, Hashable {
	case noNetwork
	case statusCode(Int)
}

extension Set where Element == CachingType {

	func statusCode(_ range: ClosedRange<Int>) -> Set<CachingType> {
		var rangeSet = Set<CachingType>()
		range.forEach { code in
			rangeSet.insert(.statusCode(code))
		}
		return rangeSet.union(self)
	}
}
