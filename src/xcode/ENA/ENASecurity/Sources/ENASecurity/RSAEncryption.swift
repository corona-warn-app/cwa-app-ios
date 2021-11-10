//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoSwift

public enum RSAEncryptionError: Error {
    case publicKeyIrretrievable
    case algorithmNotSupported
    case publicKeyMissing
    case privateKeyMissing
    case decryptionFailed(String?)
    case encryptionFailed(String?)
}

public struct RSAEncryption {

    // MARK: - Init

    public init(
        publicKeyData: Data,
        privateKeyData: Data
    ) {
        self.publicKey = publicKeyData
        self.privateKey = privateKeyData
    }

    // MARK: - Public

    public func encrypt(_ data: Data) -> Result<Data, RSAEncryptionError> {
        // check if keys are available
        guard let publicKey = publicSecKey else {
            return .failure(.publicKeyMissing)
        }
        // try to get the public key from pair or private key
        guard let publicKey = SecKeyCopyPublicKey(publicKey) else {
                  return .failure(.publicKeyIrretrievable)
              }
        // check algorithm is supporrted
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.algorithmNotSupported)
        }

        var error: Unmanaged<CFError>?
        guard let cipherData = SecKeyCreateEncryptedData(
            publicKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) as Data?,
              error == nil else {
                  return .failure(.encryptionFailed(error?.takeRetainedValue().localizedDescription))
              }
        return .success(cipherData)
    }

    public func decrypt(data: Data) -> Result<Data, RSAEncryptionError> {
        // check if keys are available
        guard let publicKey = publicSecKey else {
            return .failure(.publicKeyMissing)
        }
        guard let privateKey = privateSecKey else {
            return .failure(.privateKeyMissing)
        }
        // check algorithm is supported
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.algorithmNotSupported)
        }
        // let's try to decrypt cipher
        var error: Unmanaged<CFError>?
        guard let decodedData = SecKeyCreateDecryptedData(
            privateKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) as Data?,
              error == nil else {
                  return .failure(.decryptionFailed(error?.takeRetainedValue().localizedDescription))
              }
        return .success(decodedData)
    }

    // MARK: - Private

    private let publicKey: Data
    private let privateKey: Data

    private var publicSecKey: SecKey? {
        SecKeyCreateWithData(
            publicKey as NSData,
            [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
            ] as NSDictionary,
            nil
        )
    }

    private var privateSecKey: SecKey? {
        SecKeyCreateWithData(
            privateKey as NSData,
            [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            ] as NSDictionary,
            nil
        )
    }

}
