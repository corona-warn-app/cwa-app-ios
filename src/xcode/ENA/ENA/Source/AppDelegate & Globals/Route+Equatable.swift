////
// 🦠 Corona-Warn-App
//

import Foundation
// swiftlint:disable pattern_matching_keywords
extension Route: Equatable {
	static func == (lhs: Route, rhs: Route) -> Bool {
		switch (lhs, rhs) {
		case (.rapidAntigen(let lhsResult), .rapidAntigen(let rhsResult)):
			switch (lhsResult, rhsResult) {
			case (.failure(let lhsError), .failure(let rhsError)):
				return lhsError == rhsError
			case (.success(let lhsTestInformation), .success(let rhsTestInformation)):
				return lhsTestInformation == rhsTestInformation
			case (.success, .failure), (.failure, .success):
				return false
			}
		case (.checkIn(let lhsUrlString), .checkIn(let rhsUrlString)):
			return lhsUrlString == rhsUrlString
		case (.checkIn, .rapidAntigen), (.rapidAntigen, .checkIn):
			return false
		}
	}
}
