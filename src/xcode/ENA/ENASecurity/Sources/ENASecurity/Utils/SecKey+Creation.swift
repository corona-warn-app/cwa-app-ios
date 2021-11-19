//
// 🦠 Corona-Warn-App
//

import Foundation

public extension SecKey {
    
    // We need this since Apple expects only the raw keys no headers allowed. 🙄 and we cant use CryptoKit since we have to support iOS 12
    // Depending on where else we will need this in our awesome app we might have to move this extension into its own file. Currently its only need for unit testing
    static func privateECKey(from pemData: CFData) -> SecKey?{
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(0)) else {
            return nil
        }
        
        CFDataAppendBytes(mutableData, CFDataGetBytePtr(pemData) + 56, 65) // append public key data plus some headers
        CFDataAppendBytes(mutableData, CFDataGetBytePtr(pemData) + 7 , 32) // append private key data
        return SecKeyCreateWithData(mutableData, attributes as CFDictionary, nil)
    }
    
    static func publicECKey(from pemData: CFData) -> SecKey?{
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ]
        
        guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(0)) else {
            return nil
        }
        
        CFDataAppendBytes(mutableData, CFDataGetBytePtr(pemData), CFDataGetLength(pemData))
        CFDataDeleteBytes(mutableData, CFRangeMake(CFIndex(0), 26)) // remove public key header
        
        return SecKeyCreateWithData(mutableData, attributes as CFDictionary, nil)
    }
}
