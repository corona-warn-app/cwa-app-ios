//
// 🦠 Corona-Warn-App
//

/// possible use cases to use caching in a resource
enum CacheUseCase: Equatable, Hashable {
	case noNetwork
	case statusCode(Int)
}

extension Set where Element == CacheUseCase {

	func statusCode(_ range: ClosedRange<Int>) -> Set<CacheUseCase> {
		var rangeSet = Set<CacheUseCase>()
		range.forEach { code in
			rangeSet.insert(.statusCode(code))
		}
		return rangeSet.union(self)
	}
}
