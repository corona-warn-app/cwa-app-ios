//
// 🦠 Corona-Warn-App
//

enum MigrationError: Error {
	/// Failed from version `from` to `to`
	case failed(from: Int, to: Int)

	case general(description: String?)
}

protocol Migration {
	var version: Int { get }
	func execute() throws
}
