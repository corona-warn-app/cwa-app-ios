//
// 🦠 Corona-Warn-App
//
import Foundation

public struct ECKeyPair {
    public let privateKey: SecKey
    public let publicKey: SecKey
    
    public let publicKeyData: Data
    public let privateKeyData: Data
    
    public var publicKeyBase64: String {
        return publicKeyData.base64EncodedString()
    }
    public var privateKeyBase64: String {
        return privateKeyData.base64EncodedString()
    }
}
