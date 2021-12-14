//
// 🦠 Corona-Warn-App
//

/// type to handle caching log per resource
enum CachingType: Equatable, Hashable {
	case noNetwork
	case statusCode(Int)
	
	static func statusCodesWithRange(_ range: ClosedRange<Int>) -> Set<CachingType> {
		var statusCodes = Set<CachingType>()
		range.forEach { code in
			statusCodes.insert(.statusCode(code))
		}
		return statusCodes
	}
}

extension Set where Element == CachingType {
	
	func blubb(statusCodeRange: ClosedRange<Int>) -> Set<CachingType> {
		let rangeSet = CachingType.statusCodesWithRange(statusCodeRange)
		return rangeSet.union(self)
	}
}

extension Array where Element == CachingType {
	func blubb(statusCodeRange: ClosedRange<Int>) -> Set<CachingType> {
		let rangeSet = CachingType.statusCodesWithRange(statusCodeRange)
		return Set<CachingType>(rangeSet + self)
//		return Set<CachingType>((rangeSet + self).map { $0 })
	}
}
