//
// 🦠 Corona-Warn-App
//

import Foundation
import CommonCrypto

public enum CBCEncryptionError: Error {
    case AES_CBC_INVALID_KEY // if key cannot be used for AES
    case AES_CBC_INVALID_IV // Initialization Vector is empty or does not have the length of the provided contraint ivLengthConstraint.
    case UNKNOWN(Int)
}

public struct CBCEncryption {

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

    public func encrypt(data: Data) -> Result<Data, CBCEncryptionError> {
        return crypt(data: data, option: CCOperation(kCCEncrypt))
    }

    public func decrypt(data: Data) -> Result<Data, CBCEncryptionError> {
        return crypt(data: data, option: CCOperation(kCCDecrypt))
    }

    // MARK: - Private

    private let encryptionKey: Data
    private let initializationVector: Data
    private let ivLengthConstraint: Int?

    private func crypt(data: Data, option: CCOperation) -> Result<Data, CBCEncryptionError> {

        guard !initializationVector.isEmpty else {
            return .failure(.AES_CBC_INVALID_IV)
        }

        if let ivLengthConstraint = ivLengthConstraint {
            guard initializationVector.count == ivLengthConstraint else {
                return .failure(.AES_CBC_INVALID_IV)
            }
        }

        let cryptedDataLength = data.count + kCCBlockSizeAES128
        var cryptedData = Data(count: cryptedDataLength)
        let keyLength = encryptionKey.count
        let options = CCOptions(kCCOptionPKCS7Padding)
        var bytesLength = Int(0)

        let status = cryptedData.withUnsafeMutableBytes { cryptedBytes in
            data.withUnsafeBytes { dataBytes in
                initializationVector.withUnsafeBytes { ivBytes in
                    encryptionKey.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            option,
                            CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes.baseAddress,
                            keyLength,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            data.count,
                            cryptedBytes.baseAddress,
                            cryptedDataLength,
                            &bytesLength
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else {
            if status == kCCKeySizeError || status == kCCInvalidKey {
                return .failure(.AES_CBC_INVALID_KEY)
            }
            return .failure(.UNKNOWN(Int(status)))
        }

        cryptedData.removeSubrange(bytesLength ..< cryptedData.count)
        return .success(cryptedData)
    }
}
