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
    public let issuedAt: UInt64?
    public let expirationTime: UInt64

    public static func fake(
        issuer: String = "issuer",
        issuedAt: UInt64? = nil,
        expirationTime: UInt64 = 0
    ) -> CBORWebTokenHeader {
        CBORWebTokenHeader(
            issuer: issuer,
            issuedAt: issuedAt,
            expirationTime: expirationTime
        )
    }

}
