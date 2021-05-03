//
// 🦠 Corona-Warn-App
//

import Foundation

public struct CertificateRepresentations: Codable, Equatable {

    // MARK: - Init

    public init(base45: String, cbor: Data, json: Data) {
        self.base45 = base45
        self.cbor = cbor
        self.json = json
    }

    // MARK: - Public

    public let base45: String
    public let cbor: Data
    public let json: Data

}
