//
// 🦠 Corona-Warn-App
//

#if !RELEASE
import Foundation

/// The SRS State for Developer Menu
/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/55f037b4524df8230e4b00ee56ead650f144c690/docs/spec/data-donation-client-srs.md#data-structures
enum DMSRSState {
	
	/// The OTP that was authorized by the sever (null initially)
	/// SRS_OTP
	static var srsOTP: String?
	
	/// The OTP that was authorized by the sever (null initially)
	/// SRS_OTP_EXPIRATION_DATE
	static var srsOTPExpirationDate: Date?
}
#endif
