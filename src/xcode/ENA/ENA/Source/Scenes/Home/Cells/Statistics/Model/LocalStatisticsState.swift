//
// 🦠 Corona-Warn-App
//

import Foundation

enum LocalStatisticsState {
	/// No local stats selected
	case empty
	/// Can add more local statistics
	case notYetFull
	/// The maximum number of local statistics selected
	case full

	static func with(_ store: LocalStatisticsCaching) -> Self {
		switch store.selectedLocalStatisticsRegions.count {
		case ...0:
			return .empty
		case 1...(Self.threshold - 1):
			return .notYetFull
		case Self.threshold...: // allow over threshold values in favor to fatal errors
			return .full
		default:
			fatalError("should not happen™")
		}
	}

	/// Maximum number of custom statistics
	private static let threshold = 5
}
