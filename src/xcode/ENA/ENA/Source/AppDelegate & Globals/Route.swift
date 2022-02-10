////
// 🦠 Corona-Warn-App
//

import Foundation

enum Route: Equatable {

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
			guard let testInformation = RapidTestQRCodeInformation(payload: payloadUrl) else {
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
			
			let firstName = testInformation.firstName ?? ""
			let lastName = testInformation.lastName ?? ""
			let dateOfBirthString = testInformation.dateOfBirthString ?? ""
			let salt = testInformation.cryptographicSalt ?? ""
			let timestamp = String(testInformation.timestamp)
			let recomputedHashString: String
			
			if firstName.isEmpty && lastName.isEmpty && dateOfBirthString.isEmpty {
				// non-personalized code
				recomputedHashString = ENAHasher.sha256(timestamp + "#" + salt)
			} else {
							
				guard !firstName.isEmpty && !lastName.isEmpty && !dateOfBirthString.isEmpty else {
					self = .rapidAntigen( .failure(.invalidTestCode(.invalidTestedPersonInformation)))
					Log.error("Antigen test data for personalized code is not valid: firstName \(private: firstName), lastName \(private: lastName), dateOfBirthString: \(private: dateOfBirthString)", log: .qrCode)
					return
				}
				
				// personalized code
				var informationArray = [String]()
				informationArray.append(dateOfBirthString)
				informationArray.append(firstName)
				informationArray.append(lastName)
				informationArray.append(timestamp)
				informationArray.append(testInformation.testID ?? "")
				informationArray.append(salt)
				let informationString = informationArray.joined(separator: "#")
				recomputedHashString = ENAHasher.sha256(informationString)
			}
			
			guard recomputedHashString == testInformation.hash else {
				self = .rapidAntigen( .failure(.invalidTestCode(.hashMismatch)))
				Log.error("recomputed hash: \(recomputedHashString) Doesn't match the original hash \(testInformation.hash)", log: .qrCode)
				return
			}
			
			self = .rapidAntigen(.success(.antigen(qrCodeInformation: testInformation, qrCodeHash: ENAHasher.sha256(url.absoluteString))))
		case "p.coronawarn.app":
			guard let payloadUrl = components?.fragment,
				  let candidate = components?.query,
				  candidate.count == 3 else {
				Log.error("RapidPCR test QRCode URL is invalid", log: .qrCode)
				return nil
			}
			// extract payload
			guard let testInformation = RapidTestQRCodeInformation(payload: payloadUrl) else {
				self = .rapidPCR(.failure(.invalidTestCode(.invalidPayload)))
				Log.error("RapidPCR test data is nil, either timeStamp is -ve or the hash is invalid", log: .qrCode)
				return
			}
			guard testInformation.hash.range(of: #"^[0-9A-Fa-f]{64}$"#, options: .regularExpression) != nil  else {
				self = .rapidPCR( .failure(.invalidTestCode(.invalidHash)))
				Log.error("RapidPCR test data is nil, either timeStamp is -ve or the hash is invalid", log: .qrCode)
				return
			}
			guard  testInformation.timestamp >= 0 else {
				self = .rapidPCR( .failure(.invalidTestCode(.invalidTimeStamp)))
				Log.error("RapidPCR test data is nil, either timeStamp is -ve or the hash is invalid", log: .qrCode)
				return
			}
			
			let firstName = testInformation.firstName ?? ""
			let lastName = testInformation.lastName ?? ""
			let dateOfBirthString = testInformation.dateOfBirthString ?? ""
			let salt = testInformation.cryptographicSalt ?? ""
			let timestamp = String(testInformation.timestamp)
			let recomputedHashString: String
			
			if firstName.isEmpty && lastName.isEmpty && dateOfBirthString.isEmpty {
				// non-personalized code
				recomputedHashString = ENAHasher.sha256(timestamp + "#" + salt)
			} else {
				guard !firstName.isEmpty && !lastName.isEmpty && !dateOfBirthString.isEmpty else {
					self = .rapidPCR(.failure(.invalidTestCode(.invalidTestedPersonInformation)))
					Log.error("RapidPCR test data for personalized code is not valid: firstName \(private: firstName), lastName \(private: lastName), dateOfBirthString: \(private: dateOfBirthString)", log: .qrCode)
					return
				}
				
				// personalized code
				var informationArray = [String]()
				informationArray.append(dateOfBirthString)
				informationArray.append(firstName)
				informationArray.append(lastName)
				informationArray.append(timestamp)
				informationArray.append(testInformation.testID ?? "")
				informationArray.append(salt)
				let informationString = informationArray.joined(separator: "#")
				recomputedHashString = ENAHasher.sha256(informationString)
			}
			
			guard recomputedHashString == testInformation.hash else {
				self = .rapidPCR( .failure(.invalidTestCode(.hashMismatch)))
				Log.error("recomputed hash: \(recomputedHashString) Doesn't match the original hash \(testInformation.hash)", log: .qrCode)
				return
			}
			
			self = .rapidPCR(.success(.rapidPCR(qrCodeInformation: testInformation, qrCodeHash: ENAHasher.sha256(url.absoluteString))))
		case "e.coronawarn.app":
			self = .checkIn(url.absoluteString)
		default:
			return nil
		}
	}
	
	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate
	) {
		self = .healthCertificateFromNotification(healthCertifiedPerson, healthCertificate)
	}
	
	init(healthCertifiedPerson: HealthCertifiedPerson) {
		self = .healthCertifiedPersonFromNotification(healthCertifiedPerson)
	}

	// MARK: - Internal

	case checkIn(String)
	case rapidAntigen(Result<CoronaTestRegistrationInformation, QRCodeError>)
	case rapidPCR(Result<CoronaTestRegistrationInformation, QRCodeError>)
	case healthCertificateFromNotification(HealthCertifiedPerson, HealthCertificate)
	case healthCertifiedPersonFromNotification(HealthCertifiedPerson)
	case testResultFromNotification(CoronaTestType)
	
	var routeInformation: RouteInformation {
		switch self {
		case .checkIn:
			return .checkIn
		case .rapidAntigen:
			return .rapidAntigenTest
		case .rapidPCR:
			return .rapidPCRTest
		case .healthCertificateFromNotification:
			return .healthCertificate
		case .healthCertifiedPersonFromNotification:
			return .healthCertifiedPerson
		case .testResultFromNotification:
			return .testResult
		}
	}
}

enum RouteInformation: String {
	case checkIn = "Checkin"
	case rapidAntigenTest = "RAT"
	case rapidPCRTest = "RPCR"
	case healthCertificate = "HealthCertificate from notification"
	case healthCertifiedPerson = "HealthCertifiedPerson from notification"
	case testResult = "Testresult from notification"
}
