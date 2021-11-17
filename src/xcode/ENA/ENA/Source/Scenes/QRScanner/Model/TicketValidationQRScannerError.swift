////
// 🦠 Corona-Warn-App
//

import Foundation

enum TicketValidationQRScannerError: Error, LocalizedError {

	case INIT_DATA_PARSE_ERR
	case INIT_DATA_PROTOCOL_INVALID
	case INIT_DATA_SUBJECT_EMPTY
	case INIT_DATA_SP_EMPTY

	var errorDescription: String? {
		return AppStrings.TicketValidation.Error.serviceProviderErrorNoName + " (\(self))"
	}
	
}
