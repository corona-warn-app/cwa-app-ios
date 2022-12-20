//
// 🦠 Corona-Warn-App
//

import Foundation

struct SRSSuccessReceiveResource: ReceiveResource {
	
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = Int?

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<ReceiveModel, ResourceError> {
		if let cwaKeyTruncatedString = headers["cwa-keys-truncated"] as? String, let cwaKeyTruncated = Int(cwaKeyTruncatedString) {
			return .success(cwaKeyTruncated)
		} else {
			return .success(nil)
		}
	}
}
