//
// 🦠 Corona-Warn-App
//

/// type to handle caching log per resource
enum CachingType: Equatable, Hashable {
	case noNetwork
	case statusCode(Int)
}
