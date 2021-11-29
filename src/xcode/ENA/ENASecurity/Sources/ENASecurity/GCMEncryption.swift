//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoSwift

public enum GCMEncryptionError: Error {
    case AES_GCM_INVALID_KEY // if key cannot be used for AES
    case AES_GCM_INVALID_IV // if the iv cannot be used for AES
    case unknown(Error)
}

public struct GCMEncryption {

    // MARK: - Init

    public init(
        encryptionKey: Data,
        initializationVector: Data,
        ivLengthConstraint: Int? = nil
    ) {
        self.encryptionKey = encryptionKey
        self.initializationVector = initializationVector
        self.ivLengthConstraint = ivLengthConstraint
    }

    // MARK: - Public

    public func encrypt(data: Data) -> Result<Data, GCMEncryptionError> {
        guard isIVLengthCorrect else {
            return .failure(.AES_GCM_INVALID_IV)
        }

        do {
            let aes = try aesGCMEncryption(with: initializationVector, encryptionKey: encryptionKey)
            let encryptedBytes = try aes.encrypt(data.bytes)
            let encryptedData = Data(encryptedBytes)
            return .success(encryptedData)
        } catch {
            return .failure(gcmEncryptionError(for: error))
        }
    }

    public func decrypt(data: Data) -> Result<Data, GCMEncryptionError> {
        guard isIVLengthCorrect else {
            return .failure(.AES_GCM_INVALID_IV)
        }
        
        do {
            let aes = try aesGCMEncryption(with: initializationVector, encryptionKey: encryptionKey)
            let decryptedBytes = try aes.decrypt(data.bytes)
            let decryptedData = Data(decryptedBytes)
            return .success(decryptedData)
        } catch {
            return .failure(gcmEncryptionError(for: error))
        }
    }

    // MARK: - Private

    private let encryptionKey: Data
    private let initializationVector: Data
    private let ivLengthConstraint: Int?

    private var isIVLengthCorrect: Bool {
        if let ivLengthConstraint = ivLengthConstraint,
           initializationVector.count != ivLengthConstraint
        {
            return false
        } else {
            return true
        }
    }

    private func aesGCMEncryption(with initializationVector: Data, encryptionKey: Data) throws -> AES {
        let ivBytes = [UInt8](initializationVector)
        let gcm = GCM(
            iv: ivBytes,
            mode: .combined
        )
        let aes = try AES(
            key: [UInt8](encryptionKey),
            blockMode: gcm,
            padding: .noPadding
        )
        return aes
    }

    private func gcmEncryptionError(for error: Error) -> GCMEncryptionError {
        if let aesError = error as? CryptoSwift.AES.Error,
            aesError == .invalidKeySize {
            return .AES_GCM_INVALID_KEY
        }
        if let gcmErr = error as? GCM.Error,
           gcmErr == .invalidInitializationVector {
            return .AES_GCM_INVALID_IV
        }
        else {
            return .unknown(error)
        }
    }
}
