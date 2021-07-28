//
// 🦠 Corona-Warn-App
//

import Foundation
import Security
import CryptoKit

public struct DCCSigningCertificate {
    let kid: Data
    let data: Data

    var publicKey: SecKey? {
        if let certificate = SecCertificateCreateWithData(nil, data as CFData),
           let publicKey = SecCertificateCopyKey(certificate) {
            return publicKey
        } else {
            return nil
        }
    }

    var expirationDate: Date? {
        guard let publicKey = publicKey,
            let values = SecKeyCopyAttributes(publicKey) as? [String: Any],
            let expirationDate = values["kSecOIDInvalidityDate"] as? Date else {
            return nil
        }

        return expirationDate
    }

    var notValidAfterDate: Date? {
        guard let publicKey = publicKey,
            let values = SecKeyCopyAttributes(publicKey) as? [String: Any],
            let notValidAfter = values["kSecOIDX509V1ValidityNotAfter"] as? Int else {
            return nil
        }

        return Date(timeIntervalSince1970: Double(notValidAfter))
    }
}
