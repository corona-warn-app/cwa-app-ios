//
// 🦠 Corona-Warn-App
//

import Foundation

public struct CertificateRepresentations: Codable {

    let base45: String
    let cbor: Data
    let json: Data
}
