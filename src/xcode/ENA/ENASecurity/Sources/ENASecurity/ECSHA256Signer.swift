//
// 🦠 Corona-Warn-App
//

import Foundation


public enum ECSHA256SignerError: Error {
    case EC_SIGN_INVALID_KEY // if privateKey cannot be used for signing
    case EC_SIGN_NOT_SUPPORTED // if the algorithm is not supported
    case unknown(Error?) // Unknown error
}

public struct ECSHA256Signer {
    // MARK: - Init

    public init(privateKey: SecKey, data: Data) {
        self.privateKey = privateKey
        self.data = data
    }
    
    // MARK: - Public
    
    public func sign() -> Result<Data, ECSHA256SignerError> {
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            return .failure(.EC_SIGN_INVALID_KEY)
        }
        
        var error: Unmanaged<CFError>?
        
        guard let signature = SecKeyCreateSignature(
            privateKey,
            algorithm,
            data as CFData,
            &error
        ) as Data? else {
            return .failure(.unknown(error as? Error))
        }
        return .success(signature)
    }
    
    
    // MARK: - Internal
    let algorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256

    
    // MARK: - Private

    private let privateKey: SecKey
    private let data: Data
}


extension SecKey {
    
    // We need this since Apple expects only the raw keys no headers allowed. 🙄
    static func privateEC(from pemData: CFData) -> SecKey?{
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(0)) else {
            return nil
        }
        
        CFDataAppendBytes(mutableData, CFDataGetBytePtr(pemData) + 56, 65) // get public key data plus some headers
        CFDataAppendBytes(mutableData, CFDataGetBytePtr(pemData) + 7 , 32) // append private key data
        return SecKeyCreateWithData(mutableData, attributes as CFDictionary, nil)
    }
    
    static func publicEC(from pemData: CFData) -> SecKey?{
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ]
        
        guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(0)) else {
            return nil
        }
        
        CFDataAppendBytes(mutableData, CFDataGetBytePtr(pemData), CFDataGetLength(pemData))
        CFDataDeleteBytes(mutableData, CFRangeMake(CFIndex(0), 26)) // Remove Header
        
        return SecKeyCreateWithData(mutableData, attributes as CFDictionary, nil)
    }
}
