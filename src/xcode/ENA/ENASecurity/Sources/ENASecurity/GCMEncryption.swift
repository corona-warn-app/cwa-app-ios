//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoSwift

public enum GCMEncryptionError: Error {
    case EncryptionFailed(Error)
}

public struct GCMEncryption {

    // MARK: - Init

    public init(encryptionKey: Data, initializationVector: Data) {
        self.encryptionKey = encryptionKey
        self.initializationVector = initializationVector
    }

    // MARK: - Public

    public func encrypt(data: Data) -> Result<Data, GCMEncryptionError> {
        do {
            let aes = try AES(
                key: [UInt8](encryptionKey),
                blockMode: GCM(iv: [UInt8](initializationVector)),
                padding: .pkcs7
            )
            let encryptedBytes = try aes.encrypt(data.bytes)
            let encryptedData = Data(encryptedBytes)
            return .success(encryptedData)
        } catch {
            return .failure(.EncryptionFailed(error))
        }
    }

    public func decrypt(data: Data) -> Result<Data, GCMEncryptionError> {
        do {
            let aes = try AES(
                key: [UInt8](encryptionKey),
                blockMode: GCM(iv: [UInt8](initializationVector)),
                padding: .pkcs7
            )
            let decryptedBytes = try aes.decrypt(data.bytes)
            let decryptedData = Data(decryptedBytes)
            return .success(decryptedData)
        } catch {
            return .failure(.EncryptionFailed(error))
        }
    }

    // MARK: - Private

    private let encryptionKey: Data
    private let initializationVector: Data
}
