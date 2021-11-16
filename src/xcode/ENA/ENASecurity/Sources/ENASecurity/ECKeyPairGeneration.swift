//
// 🦠 Corona-Warn-App
//

import Foundation

public struct ECKeyPairGeneration {
    
    // MARK: - Public

    public func generatePrivateKey(with name: String? = nil) -> (SecKey?, String?) {
      let name = name ?? UUID().uuidString
      let tag = tag(for: name)
      var error: Unmanaged<CFError>?
      guard
        let access =
          SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage],
            &error
          )
      else {
        return (nil, error?.takeRetainedValue().localizedDescription)
      }
      var attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeEC,
        kSecAttrKeySizeInBits as String: 256,
        kSecPrivateKeyAttrs as String: [
          kSecAttrApplicationTag as String: tag,
          kSecAttrAccessControl as String: access
        ]
      ]
        
      #if !targetEnvironment(simulator)
      attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
      #endif
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
    
    public func generatePublicKey(from privateKey: SecKey) -> SecKey? {
        return SecKeyCopyPublicKey(privateKey)
    }
    
    public func generateData(from key: SecKey) -> (Data?, String?) {
        var error: Unmanaged<CFError>?

        guard let keyCFData = SecKeyCopyExternalRepresentation(key, &error) else {
            let convertedError = error!.takeRetainedValue() as Error
            return (nil, convertedError.localizedDescription)
        }
        let modifiedData = prependHeaderToData(data: keyCFData as Data)
        
        return (modifiedData, nil)
    }
    
    // MARK: - Private
    
    private func tag(for name: String) -> Data {
      "\(Bundle.main.bundleIdentifier ?? "app").\(name)".data(using: .utf8)!
    }
    
    private func prependHeaderToData(data: Data) -> Data {
        var appendedData = data
        let headerBytes = [0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00] as [UInt8]
        appendedData.insert(contentsOf: headerBytes, at: 0)
        
        return appendedData
    }

}
