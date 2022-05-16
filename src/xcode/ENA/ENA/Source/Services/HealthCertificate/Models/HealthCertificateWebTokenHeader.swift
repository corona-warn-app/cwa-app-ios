//
// 🦠 Corona-Warn-App
//

import Foundation

public struct HealthCertificateWebTokenHeader: Codable, Equatable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case issuer = "iss"
		case issuedAt = "iat"
		case expirationTime = "exp"
	}

	// MARK: - Internal

	public let issuer: String
	public let issuedAt: Double
	public let expirationTime: Double

}
