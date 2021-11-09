//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoSwift

public enum GCMEncryptionError: Error {
    case EncryptionFailed(Int)
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
            let inputData = Data()
            let encryptedBytes = try aes.encrypt(inputData.bytes)
            let encryptedData = Data(encryptedBytes)
            return .success(encryptedData)
        } catch {
            return .failure(.EncryptionFailed(0))
        }
    }

    public func decrypt(data: Data) -> Result<Data, GCMEncryptionError> {
        do {
            let aes = try AES(
                key: [UInt8](encryptionKey),
                blockMode: GCM(iv: [UInt8](initializationVector)),
                padding: .pkcs7
            )
            let inputData = Data()
            let decryptedBytes = try aes.decrypt(inputData.bytes)
            let decryptedData = Data(decryptedBytes)
            return .success(decryptedData)
        } catch {
            return .failure(.EncryptionFailed(0))
        }
    }

    // MARK: - Private

    private let encryptionKey: Data
    private let initializationVector: Data
}
