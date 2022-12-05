//
// 🦠 Corona-Warn-App
//

struct SRSSuccessReceiveResource: ReceiveResource {
	
	typealias ReceiveModel = Int?

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<ReceiveModel, ResourceError> {
		if let cwaKeyTruncated = headers["cwa-keys-truncated"] as? Int {
			return .success(cwaKeyTruncated)
		} else {
			return .success(nil)
		}
	}
}
