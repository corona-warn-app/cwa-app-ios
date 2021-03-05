////
// 🦠 Corona-Warn-App
//

protocol SchemaProtocol {
	func create() -> Result<Void, SQLiteErrorCode>
}
