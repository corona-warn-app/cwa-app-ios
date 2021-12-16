//
// 🦠 Corona-Warn-App
//

/// The different services we can use to send and receive resources as enum
enum ServiceType {
	case `default`
	case caching(Set<CacheUseCase> = [])
	case wifiOnly
	case retrying
	case dynamicPinning
	case disabledPinning
}
