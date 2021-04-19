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
				  testInformation.guid.range(
					of: #"^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"#,
					options: .regularExpression
				  ) != nil,
				  testInformation.guid.count == 36,
				  testInformation.timestamp >= 0
			else {
				self = .rapidAntigen( .failure(.invalidTestCode))
				return
			}

			// Check in case the dateOfBirth is available, that it is in the correct format
			if let dateOfBirth = testInformation.dateOfBirth {
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd"
				guard dateFormatter.date(from: dateOfBirth) != nil else {
					self = .rapidAntigen( .failure(.invalidTestCode))
					return
				}
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
