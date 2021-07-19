//
// 🦠 Corona-Warn-App
//

import Foundation

public struct CBORWebTokenHeader: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case issuedAt = "iat"
        case expirationTime = "exp"
    }

    // MARK: - Internal

    public let issuer: String
    public let issuedAt: Date
    public let expirationTime: Date

    public static func fake(
        issuer: String = "issuer",
        issuedAt: Date = Date(),
        expirationTime: Date = Date(timeIntervalSince1970: 0)
    ) -> CBORWebTokenHeader {
        CBORWebTokenHeader(
            issuer: issuer,
            issuedAt: issuedAt,
            expirationTime: expirationTime
        )
    }

}
