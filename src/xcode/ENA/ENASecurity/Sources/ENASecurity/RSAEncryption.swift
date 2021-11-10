//
// 🦠 Corona-Warn-App
//

import Foundation

public enum RSAEncryptionError: Error {
    case RSA_ENC_INVALID_KEY // public key cannot be used for encryption
    case RSA_ENC_NOT_SUPPORTED // algorithm is not supported
    case unknown(String?)
}

public struct RSAEncryption {

    // MARK: - Init

    public init(
        publicKey: SecKey,
        privateKey: SecKey
    ) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    // MARK: - Public

    public func encrypt(_ data: Data) -> Result<Data, RSAEncryptionError> {
        // try to get the public key from pair or private key
        guard let publicKey = SecKeyCopyPublicKey(publicKey) else {
                  return .failure(.RSA_ENC_INVALID_KEY)
              }
        // check algorithm is supporrted
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.RSA_ENC_NOT_SUPPORTED)
        }

        var error: Unmanaged<CFError>?
        guard let cipherData = SecKeyCreateEncryptedData(
            publicKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) as Data?,
              error == nil else {
                  return .failure(.unknown(error?.takeRetainedValue().localizedDescription))
              }
        return .success(cipherData)
    }

    public func decrypt(data: Data) -> Result<Data, RSAEncryptionError> {
        // check algorithm is supported
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.RSA_ENC_NOT_SUPPORTED)
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
                  return .failure(.unknown(error?.takeRetainedValue().localizedDescription))
              }
        return .success(decodedData)
    }

    // MARK: - Private

    private let publicKey: SecKey
    private let privateKey: SecKey

    /*
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
     */

}
