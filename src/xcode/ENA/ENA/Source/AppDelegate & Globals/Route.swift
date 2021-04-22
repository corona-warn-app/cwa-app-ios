////
// 🦠 Corona-Warn-App
//

import Foundation

enum Route {

	// MARK: - Init

	init?(_ stringURL: String?) {
		guard let stringURL = stringURL,
			let url = URL(string: stringURL) else {
			return nil
		}
		self.init(url: url)
	}

	init?(url: URL) {
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard let host = components?.host?.lowercased() else {
			return nil
		}

		switch host {
		case "s.coronawarn.app":
			guard let payloadUrl = components?.fragment,
				  let candidate = components?.query,
				  candidate.count == 3 else {
				return nil
			}

			// extract payload
			guard let testInformation = AntigenTestInformation(payload: payloadUrl),
				  testInformation.hash.range(
					of: #"^[0-9A-Fa-f]{64}$"#,
					options: .regularExpression
				  ) != nil,
				  testInformation.timestamp >= 0
			else {
				self = .rapidAntigen( .failure(.invalidTestCode))
				return
			}
			let allIsNil = testInformation.firstName == nil && testInformation.firstName == nil && testInformation.dateOfBirthString == nil
			// dateOfBirth is nil if dateOfBirthString is nil OR if dateOfBirthString is invalid
			let allIsValid = testInformation.firstName != nil && testInformation.firstName != nil && testInformation.dateOfBirth != nil
			
			guard allIsNil || allIsValid else {
				self = .rapidAntigen( .failure(.invalidTestCode))
				return
			}
			self = .rapidAntigen(.success(.antigen(testInformation)))

		case "e.coronawarn.app":
			self = .checkIn(url.absoluteString)

		default:
			return nil
		}
	}

	// MARK: - Internal

	case checkIn(String)
	case rapidAntigen(Result<CoronaTestQRCodeInformation, QRCodeError>)

}
