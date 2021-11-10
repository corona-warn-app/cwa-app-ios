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

public enum RSADecryptionError: Error {
    case publicKeyIrretrievable
    case algorithmNotSupported
    case decryptionFailed(String?)
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
        // check algorithm is sipporrted
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

    public func decrypt(privateKey: SecKey, cipherData: Data) -> Result<Data, RSADecryptionError> {

        // check algorithm is sipporrted
//        guard SecKeyIsAlgorithmSupported(privateKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
//            return .failure(.algorithmNotSupported)
//        }
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return .failure(.algorithmNotSupported)
        }


        var error: Unmanaged<CFError>?

        guard let decodedData = SecKeyCreateDecryptedData(
            privateKey,
            SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
            cipherData as CFData,
            &error
        ) as Data?,
              error == nil else {
                  return .failure(.decryptionFailed(error?.takeRetainedValue().localizedDescription))
              }
        return .success(decodedData)
    }

    public func decode(privateKey: SecKey, _ encrypted: [UInt8]) -> Result<String, RSADecryptionError> {
        var plaintextBufferSize = Int(SecKeyGetBlockSize(privateKey))
        var plaintextBuffer = [UInt8](repeating:0, count:Int(plaintextBufferSize))

        let status = SecKeyDecrypt(privateKey, SecPadding.PKCS1, encrypted, plaintextBufferSize, &plaintextBuffer, &plaintextBufferSize)

        if (status != errSecSuccess) {
            return .failure(.decryptionFailed(nil))
        }
        if let resultString = String(bytesNoCopy: &plaintextBuffer, length: plaintextBufferSize, encoding: .utf8, freeWhenDone: true) {
            return .success(resultString)
        }
        else {
            return .failure(.decryptionFailed("failed to convert to string"))
        }
    }

    /*
    func encrypt(text: String) -> [UInt8] {
        let plainBuffer = [UInt8](text.utf8)
        var cipherBufferSize : Int = Int(SecKeyGetBlockSize((self.publicKey)!))
        var cipherBuffer = [UInt8](repeating:0, count:Int(cipherBufferSize))

        // Encrypto  should less than key length
        let status = SecKeyEncrypt((self.publicKey)!, SecPadding.PKCS1, plainBuffer, plainBuffer.count, &cipherBuffer, &cipherBufferSize)
        if (status != errSecSuccess) {
            print("Failed Encryption")
        }
        return cipherBuffer
    }

    func decprypt(encrpted: [UInt8]) -> String? {
        var plaintextBufferSize = Int(SecKeyGetBlockSize((self.privateKey)!))
        var plaintextBuffer = [UInt8](repeating:0, count:Int(plaintextBufferSize))

        let status = SecKeyDecrypt((self.privateKey)!, SecPadding.PKCS1, encrpted, plaintextBufferSize, &plaintextBuffer, &plaintextBufferSize)

        if (status != errSecSuccess) {
            print("Failed Decrypt")
            return nil
        }
        return NSString(bytes: &plaintextBuffer, length: plaintextBufferSize, encoding: String.Encoding.utf8.rawValue)! as String
    }
*/
    // MARK: - Internal

    // MARK: - Private

    private let publicKey: SecKey

}
