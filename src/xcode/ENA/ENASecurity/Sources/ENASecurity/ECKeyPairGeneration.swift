//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

public enum ECKeyPairGenerationError: Error {
    case privateKeyGenerationError(String?) // if key cannot be used for AES
    case publicKeyGenerationFailed // if key cannot be used for AES
    case dataGenerationFromKeyFailed(String?) // if key cannot be used for AES
}

public struct ECKeyPairGeneration {

    // MARK: - Init

    public init() {

    }
    
    // MARK: - Public

    public func generateECPair() -> Result<ECKeyPair, ECKeyPairGenerationError> {
        let secureKey = self.generatePrivateKey()
        guard let privateKey = secureKey.0 else {
            return .failure(.privateKeyGenerationError(secureKey.1))
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return .failure(.publicKeyGenerationFailed)
        }
        let generatedPrivateKeyData = generateData(from: privateKey)
        guard let privateKeyData = generatedPrivateKeyData.0 else {
            return .failure(.dataGenerationFromKeyFailed(generatedPrivateKeyData.1))
        }

        let generatedPublicKeyData = generateData(from: publicKey)
        guard let publicKeyData = generatedPublicKeyData.0 else {
            return .failure(.dataGenerationFromKeyFailed(generatedPublicKeyData.1))
        }
        
        return .success(
            ECKeyPair(
                privateKey: privateKey,
                publicKey: publicKey,
                publicKeyData: publicKeyData,
                privateKeyData: privateKeyData
            )
        )
    }
    
    // MARK: - Private
    
    private func generatePrivateKey() -> (SecKey?, String?) {
        var error: Unmanaged<CFError>?

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256
        ]

        guard
            let privateKey = SecKeyCreateRandomKey(
                attributes as CFDictionary,
                &error
            )
        else {
            return (nil, error?.takeRetainedValue().localizedDescription)
        }
        return (privateKey, nil)
    }

    private func generateData(from key: SecKey) -> (Data?, String?) {
        var error: Unmanaged<CFError>?

        guard let keyCFData = SecKeyCopyExternalRepresentation(key, &error) else {
            let convertedError = error!.takeRetainedValue() as Error
            return (nil, convertedError.localizedDescription)
        }
        let modifiedData = prependHeaderToData(data: keyCFData as Data)
        
        return (modifiedData, nil)
    }

    private func prependHeaderToData(data: Data) -> Data {
        var appendedData = data
        let headerBytes = [0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00] as [UInt8]
        appendedData.insert(contentsOf: headerBytes, at: 0)
        
        return appendedData
    }
}
