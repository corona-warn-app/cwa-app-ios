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
	// swiftlint:disable:next cyclomatic_complexity
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
				Log.error("Antigen test QRCode URL is invalid", log: .qrCode)
				return nil
			}

			// extract payload
			guard let testInformation = AntigenTestInformation(payload: payloadUrl) else {
				self = .rapidAntigen( .failure(.invalidTestCode(.invalidPayload)))
				Log.error("Antigen test data is nil, either timeStamp is -ve or the hash is invalid", log: .qrCode)
				return
			}
			guard testInformation.hash.range(of: #"^[0-9A-Fa-f]{64}$"#, options: .regularExpression) != nil  else {
				self = .rapidAntigen( .failure(.invalidTestCode(.invalidHash)))
				Log.error("Antigen test data is nil, either timeStamp is -ve or the hash is invalid", log: .qrCode)
				return
			}
			guard  testInformation.timestamp >= 0 else {
				self = .rapidAntigen( .failure(.invalidTestCode(.invalidTimeStamp)))
				Log.error("Antigen test data is nil, either timeStamp is -ve or the hash is invalid", log: .qrCode)
				return
			}
			let allIsNil = testInformation.firstName == nil && testInformation.lastName == nil && testInformation.dateOfBirthString == nil
			// dateOfBirth is nil if dateOfBirthString is nil OR if dateOfBirthString is invalid
			let allIsValid = testInformation.firstName != nil && testInformation.lastName != nil && testInformation.dateOfBirth != nil
			
			guard allIsNil || allIsValid else {
				self = .rapidAntigen( .failure(.invalidTestCode(.invalidTestedPersonInformation)))
				Log.error("Antigen test data is not valid: all values are nil? \(allIsNil), all values are valid? \(allIsValid)", log: .qrCode)
				return
			}
			
			if allIsValid {
				var informationArray = [String]()
				informationArray.append(testInformation.dateOfBirthString ?? "")
				informationArray.append(testInformation.firstName ?? "")
				informationArray.append(testInformation.lastName ?? "")
				informationArray.append(String(testInformation.timestamp))
				informationArray.append(testInformation.testID ?? "")
				informationArray.append(testInformation.cryptographicSalt ?? "")

				let informationString = informationArray.joined(separator: "#")
				let recomputedHashString = ENAHasher.sha256(informationString)
				guard recomputedHashString == testInformation.hash else {
					self = .rapidAntigen( .failure(.invalidTestCode(.hashMismatch)))
					Log.error("recomputed hash: \(recomputedHashString) Doesn't match the original hash \(testInformation.hash)", log: .qrCode)
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
