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



