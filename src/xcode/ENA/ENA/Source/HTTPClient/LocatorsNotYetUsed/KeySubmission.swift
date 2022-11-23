//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	ProtoBuf SAP_Internal_SubmissionPayload
	// receive:	Empty
	// type:
	// comment:	Custom error handling required
	static func keySubmission(
		payload: SubmissionPayload? = nil,
		srsOtp: String? = nil,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let fakePadding = isFake ? String.getRandomString(of: 36) : ""
		
		// we have an extra special key in the header to differentiate SRS from normal submission
		// for that we have the optional srsOtp argument in the function and based on it we
		// either add the srs header or the normal submission header
		if let srsOtp = srsOtp {
			// SRS submission
			return Locator(
				endpoint: .submission,
				paths: ["version", "v1", "diagnosis-keys"],
				method: .post,
				defaultHeaders: [
					"Content-Type": "application/x-protobuf",
					"cwa-otp": srsOtp,
					"cwa-fake": fake,
					"cwa-header-padding": fakePadding
				]
			)
		} else {
			// Normal submission
			return Locator(
				endpoint: .submission,
				paths: ["version", "v1", "diagnosis-keys"],
				method: .post,
				defaultHeaders: [
					"Content-Type": "application/x-protobuf",
					"cwa-authorization": payload?.tan ?? "",
					"cwa-fake": fake,
					"cwa-header-padding": fakePadding
				]
			)
		}
	}

}
