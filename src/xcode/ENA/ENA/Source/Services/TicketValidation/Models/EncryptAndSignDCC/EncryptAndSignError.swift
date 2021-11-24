//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

enum EncryptAndSignError: Error {
	case AES_CBC_ERROR(CBCEncryptionError)
	case AES_GCM_ERROR(GCMEncryptionError)
	case RSA_ENC_ERROR(RSAEncryptionError)
	case EC_SIGN_ERROR(ECSHA256SignerError)
	case UNKNOWN
}
