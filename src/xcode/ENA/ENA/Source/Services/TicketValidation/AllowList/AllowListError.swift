//
// 🦠 Corona-Warn-App
//

enum AllowListError: LocalizedError {
	case CERT_PIN_HOST_MISMATCH
	case SP_ALLOWLIST_NO_MATCH
	case REST_SERVICE_ERROR(ServiceError<AllowListResource.CustomError>)
	
	var localizedDescription: String {
		switch self {
		case .CERT_PIN_HOST_MISMATCH:
			return "CERT_PIN_HOST_MISMATCH"
		case .SP_ALLOWLIST_NO_MATCH:
			return "SP_ALLOWLIST_NO_MATCH"
		case .REST_SERVICE_ERROR(let serviceError):
			return "REST_SERVICE_ERROR \(serviceError.localizedDescription)"
		}
	}
}
