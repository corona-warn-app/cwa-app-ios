//
// 🦠 Corona-Warn-App
//

protocol SRSErrorAlertProviding: Error {
	/// The SRS Error Alert type aims to share error message based on error codes.
	/// The type is optional, because there are error cases of error enums, that hasn't a relationship to SRS
	var srsErrorAlert: SRSErrorAlert? { get }
}
