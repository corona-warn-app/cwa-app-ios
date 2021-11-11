//
// 🦠 Corona-Warn-App
//

import Foundation
import CommonCrypto

public enum CBCEncryptionError: Error {
    case EncryptionFailed(Int)
}

public struct CBCEncryption {

    // MARK: - Init

    public init(encryptionKey: Data, initializationVector: Data) {
        self.encryptionKey = encryptionKey
        self.initializationVector = initializationVector
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

    private func crypt(data: Data, option: CCOperation) -> Result<Data, CBCEncryptionError> {
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
            return .failure(.EncryptionFailed(Int(status)))
        }

        cryptedData.removeSubrange(bytesLength ..< cryptedData.count)
        return .success(cryptedData)
    }
}
