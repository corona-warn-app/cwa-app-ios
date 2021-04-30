//
// 🦠 Corona-Warn-App
//

import Foundation

public struct CertificateRepresentations: Codable {

    public let base45: String
    public let cbor: Data
    public let json: Data

}
