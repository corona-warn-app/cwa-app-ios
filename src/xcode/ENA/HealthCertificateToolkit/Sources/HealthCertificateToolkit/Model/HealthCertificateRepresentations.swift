//
// 🦠 Corona-Warn-App
//

import Foundation

public struct HealthCertificateRepresentations: Codable {

    let base45: String
    let cbor: Data
    let json: Data
}
