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
}
