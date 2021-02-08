//
// 🦠 Corona-Warn-App
//

extension String {

	func numericGreaterOrEqual(then otherString: String) -> Bool {
		return compare(otherString, options: .numeric) != .orderedAscending
	}
	
	func numericGreater(then otherString: String) -> Bool {
		return compare(otherString, options: .numeric) != .orderedAscending && compare(otherString, options: .numeric) != .orderedSame
	}
}
