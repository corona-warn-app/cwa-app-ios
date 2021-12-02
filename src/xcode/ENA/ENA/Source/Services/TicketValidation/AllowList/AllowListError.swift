//
// 🦠 Corona-Warn-App
//

enum AllowListError: Error {
	case CERT_PIN_HOST_MISMATCH
	case CERT_PIN_MISMATCH
	case SP_ALLOWLIST_NO_MATCH
	case REST_SERVICE_ERROR(ServiceError<AllowListResource.CustomError>)
}
