//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoSwift

public enum RSAEncryptionError {
    case encryptionFailed
}

public struct RSAEncryption {

    // MARK: - Init

    init(
        _ publicKey: Data
    ) {
        self.publicKey = publicKey
    }

    // MARK: - Overrides

    // MARK: - Protocol <#Name#>

    // MARK: - Public

    public func encrypt(_ plainText: Data) -> Result<Data, RSAEncryptionError> {

    }

    // MARK: - Internal

    // MARK: - Private

    private let publicKey: Data

}
