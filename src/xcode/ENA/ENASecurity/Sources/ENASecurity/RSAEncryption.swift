//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoSwift

public enum RSAEncryptionError: Error {
    case publicKeyIrretrievable
    case algorithmNotSupported
    case encryptionFailed(String?)
}

public struct RSAEncryption {

    // MARK: - Init

    init(
        _ publicKey: SecKey
    ) {
        self.publicKey = publicKey
    }

    // MARK: - Overrides

    // MARK: - Protocol <#Name#>

    // MARK: - Public

    public func encrypt(_ plainText: Data) -> Result<Data, RSAEncryptionError> {
        // try to get the public key from pair or private key
        guard let publicKey = SecKeyCopyPublicKey(publicKey) else {
            return .failure(.publicKeyIrretrievable)
        }
        //
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.algorithmNotSupported)
        }

        var error: Unmanaged<CFError>?
        guard let cipherData = SecKeyCreateEncryptedData(
            publicKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            plainText as CFData,
            &error
        ) as Data?,
              error == nil else {
                  return .failure(.encryptionFailed(error?.takeRetainedValue().localizedDescription))
              }
        return .success(cipherData)
    }

    // MARK: - Internal

    // MARK: - Private

    private let publicKey: SecKey

}
