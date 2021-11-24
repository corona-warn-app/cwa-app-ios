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
    
    public init() {}

    // MARK: - Public

    public func encrypt(_ data: Data, publicKey: SecKey) -> Result<Data, RSAEncryptionError> {
        // check algorithm is supported
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.RSA_ENC_NOT_SUPPORTED)
        }
        return encode(data, publicKey: publicKey)
    }

    public func decrypt(data: Data, privateKey: SecKey) -> Result<Data, RSAEncryptionError> {
        // check algorithm is supported
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.RSA_ENC_NOT_SUPPORTED)
        }
        return decode(data, privateKey: privateKey)
    }

    // MARK: - Private

    private func decode(_ data: Data, privateKey: SecKey) -> Result<Data, RSAEncryptionError> {
        var error: Unmanaged<CFError>?
        let decodedData = SecKeyCreateDecryptedData(
            privateKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) as Data?

        if let errorText = error?.takeRetainedValue().localizedDescription {
            return .failure(.unknown(errorText))
        } else if let data = decodedData {
            return .success(data)
        } else {
            return .failure(.unknown(nil))
        }
    }

    private func encode(_ data: Data, publicKey: SecKey) -> Result<Data, RSAEncryptionError> {
        var error: Unmanaged<CFError>?
        let cipherData = SecKeyCreateEncryptedData(
            publicKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) as Data?

        if let errorText = error?.takeRetainedValue().localizedDescription {
            return .failure(.unknown(errorText))
        } else if let data = cipherData {
            return .success(data)
        } else {
            return .failure(.unknown(nil))
        }
    }

}
