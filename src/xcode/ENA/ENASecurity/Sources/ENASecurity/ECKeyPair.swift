//
// 🦠 Corona-Warn-App
//
import Foundation

public struct ECKeyPair {
    let privateKey: SecKey
    let publicKey: SecKey
    
    let publicKeyData: Data
    let privateKeyData: Data
    
    var publicKeyBase64: String {
        return publicKeyData.base64EncodedString()
    }
    var privateKeyBase64: String {
        return privateKeyData.base64EncodedString()
    }
}
