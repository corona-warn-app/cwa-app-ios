////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class TestCertificateRequest: Codable {

	// MARK: - Init

	init(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date,
		rsaKeyPair: DCCRSAKeyPair? = nil,
		rsaPublicKeyRegistered: Bool = false,
		encryptedDEK: String? = nil,
		encryptedCOSE: String? = nil,
		requestExecutionFailed: Bool = false
	) {
		self.coronaTestType = coronaTestType
		self.registrationToken = registrationToken
		self.registrationDate = registrationDate
		self.rsaKeyPair = rsaKeyPair
		self.rsaPublicKeyRegistered = rsaPublicKeyRegistered
		self.encryptedDEK = encryptedDEK
		self.encryptedCOSE = encryptedCOSE
		self.requestExecutionFailed = requestExecutionFailed
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case coronaTestType
		case registrationToken
		case registrationDate
		case rsaKeyPair
		case rsaPublicKeyRegistered
		case encryptedDEK
		case encryptedCOSE
		case requestExecutionFailed
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		coronaTestType = try container.decode(CoronaTestType.self, forKey: .coronaTestType)
		registrationToken = try container.decode(String.self, forKey: .registrationToken)
		registrationDate = try container.decode(Date.self, forKey: .registrationDate)
		rsaKeyPair = try container.decodeIfPresent(DCCRSAKeyPair.self, forKey: .rsaKeyPair)
		rsaPublicKeyRegistered = try container.decode(Bool.self, forKey: .rsaPublicKeyRegistered)
		encryptedDEK = try container.decodeIfPresent(String.self, forKey: .encryptedDEK)
		encryptedCOSE = try container.decodeIfPresent(String.self, forKey: .encryptedCOSE)
		requestExecutionFailed = try container.decode(Bool.self, forKey: .requestExecutionFailed)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(coronaTestType, forKey: .coronaTestType)
		try container.encode(registrationToken, forKey: .registrationToken)
		try container.encode(registrationDate, forKey: .registrationDate)
		try container.encode(rsaKeyPair, forKey: .rsaKeyPair)
		try container.encode(rsaPublicKeyRegistered, forKey: .rsaPublicKeyRegistered)
		try container.encode(encryptedDEK, forKey: .encryptedDEK)
		try container.encode(encryptedCOSE, forKey: .encryptedCOSE)
		try container.encode(requestExecutionFailed, forKey: .requestExecutionFailed)
	}

	// MARK: - Internal

	let coronaTestType: CoronaTestType
	let registrationToken: String
	let registrationDate: Date

	var rsaKeyPair: DCCRSAKeyPair? {
		didSet {
			if rsaKeyPair != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var rsaPublicKeyRegistered: Bool {
		didSet {
			if rsaPublicKeyRegistered != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var encryptedDEK: String? {
		didSet {
			if encryptedDEK != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var encryptedCOSE: String? {
		didSet {
			if encryptedCOSE != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var requestExecutionFailed: Bool {
		didSet {
			if requestExecutionFailed != oldValue {
				objectDidChange.send(self)
			}
		}
	}

	var objectDidChange = OpenCombine.PassthroughSubject<TestCertificateRequest, Never>()

}
