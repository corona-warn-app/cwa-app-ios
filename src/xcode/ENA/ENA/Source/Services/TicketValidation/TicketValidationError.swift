//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

enum TicketValidationError: LocalizedError {
	case validationDecoratorDocument(ServiceIdentityValidationDecoratorError)
	case validationServiceDocument(ServiceIdentityRequestError)
	case keyPairGeneration(ECKeyPairGenerationError)
	case accessToken(TicketValidationAccessTokenProcessingError)
	case encryption(EncryptAndSignError)
	case VS_ID_NO_ENC_KEY
	case resultToken(TicketValidationResultTokenProcessingError)
	case other
}
