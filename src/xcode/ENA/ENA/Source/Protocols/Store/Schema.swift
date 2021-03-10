////
// 🦠 Corona-Warn-App
//

protocol StoreSchemaProtocol {
	func create() -> Result<Void, SQLiteErrorCode>
}
