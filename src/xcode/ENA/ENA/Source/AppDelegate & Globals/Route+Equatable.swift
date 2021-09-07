////
// 🦠 Corona-Warn-App
//

import Foundation
// swiftlint:disable pattern_matching_keywords
extension Route: Equatable {
	// swiftlint:disable:next cyclomatic_complexity
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
		case (.healthCertificateFromNotification(_, let lhsHealthCertificate), .healthCertificateFromNotification(_, let rhsHealthCertificate)):
			return lhsHealthCertificate == rhsHealthCertificate
		case (.healthCertificateFromNotification, .checkIn):
			return false
		case (.healthCertificateFromNotification, .rapidAntigen):
			return false
		case (.checkIn, .healthCertificateFromNotification):
			return false
		case (.rapidAntigen, .healthCertificateFromNotification):
			return false
		case (.healthCertifiedPersonFromNotification(let lhsHealthCertifiedPerson), .healthCertifiedPersonFromNotification(let rhsHealthCertifiedPerson)):
			return lhsHealthCertifiedPerson == rhsHealthCertifiedPerson
		case (.healthCertifiedPersonFromNotification, .checkIn):
			return false
		case (.healthCertifiedPersonFromNotification, .rapidAntigen):
			return false
		case (.healthCertifiedPersonFromNotification, .healthCertificateFromNotification):
			return false
		case (.healthCertificateFromNotification, .healthCertifiedPersonFromNotification):
			return false
		case (.checkIn, .healthCertifiedPersonFromNotification):
			return false
		case (.rapidAntigen, .healthCertifiedPersonFromNotification):
			return false
		}
	}
}
