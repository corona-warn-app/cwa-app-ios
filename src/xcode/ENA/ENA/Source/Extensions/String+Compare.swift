//
// 🦠 Corona-Warn-App
//

extension String {

	func numericGreaterOrEqual(then otherString: String) -> Bool {
		return compare(otherString, options: .numeric) != .orderedAscending
	}
}
