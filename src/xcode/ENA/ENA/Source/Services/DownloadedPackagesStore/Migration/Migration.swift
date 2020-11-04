protocol Migration {
	func execute(completed: (Bool) -> Void)
}
