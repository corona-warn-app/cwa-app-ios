//
// 🦠 Corona-Warn-App
//

enum AllowListError: LocalizedError {
	case SP_ALLOWLIST_NO_MATCH
	case REST_SERVICE_ERROR(ServiceError<AllowListResource.CustomError>)
}
