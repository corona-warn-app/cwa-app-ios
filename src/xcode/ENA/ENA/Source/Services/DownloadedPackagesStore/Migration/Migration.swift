//
// 🦠 Corona-Warn-App
//

protocol Migration {
	func execute(completed: (Bool) -> Void)
}
