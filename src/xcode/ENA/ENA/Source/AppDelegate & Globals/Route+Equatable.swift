////
// 🦠 Corona-Warn-App
//

import Foundation
// swiftlint:disable cyclomatic_complexity
extension Route: Equatable {
	static func == (lhs: Route, rhs: Route) -> Bool {
		switch lhs {
		case .rapidAntigen(let lhsResult):
			switch rhs {
			case .rapidAntigen(let rhsResult):
				// lhs = rapidAntigen, rhs = rapidAntigen
				switch lhsResult {
				// comparing rapidAntigen results on both sides
				case .failure(let lhsError):
					switch rhsResult {
					case .failure(let rhsError):
						// lhs = failure, rhs = failure --> compare the error codes and return the result
						return lhsError == rhsError
					case .success:
						// lhs = failure, rhs = success
						return false
					}
				case .success(let lhsTestInformation):
					switch rhsResult {
					case .success(let rhsTestInformation):
						// lhs = success, rhs = success --> compare the CoronaTestQRCodeInformation codes and return the result
						return lhsTestInformation == rhsTestInformation
					case .failure:
						// lhs = success, rhs = failure
						return false
					}
				}
			case .checkIn:
				// lhs = rapidAntigen, rhs = checkIn
				return false
			}
		// comparing checkIn on both checkIn
		case .checkIn(let lhsUrlString):
			switch rhs {
			case .checkIn(let rhsUrlString):
				// lhs = checkIn, rhs = checkIn, compare the URL strings and return the result
				return lhsUrlString == rhsUrlString
			case .rapidAntigen:
				// lhs = checkIn, rhs = rapidAntigen
				return false
			}
		}
	}
}
