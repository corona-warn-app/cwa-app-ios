//
// 🦠 Corona-Warn-App
//

protocol ErrorCodeProviding: Error {
	typealias ErrorCode = String
	/// Error Code
	var description: ErrorCode { get }
}
