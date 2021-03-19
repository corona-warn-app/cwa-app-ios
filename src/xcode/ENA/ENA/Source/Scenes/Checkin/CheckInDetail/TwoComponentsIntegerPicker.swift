////
// 🦠 Corona-Warn-App
//

struct TwoComponentsIntegerPicker {
	var firstComponentSelectedValue: Int?
	var secondComponentSelectedValue: Int?
	let firstComponentValues: [Int]
	let secondComponentValues: [Int]
	
	init(
		firstComponentSelectedValue: Int?,
		secondComponentSelectedValue: Int?,
		firstComponentValues: [Int],
		secondComponentValues: [Int]
	) {
		self.firstComponentSelectedValue = firstComponentSelectedValue
		self.secondComponentSelectedValue = secondComponentSelectedValue
		self.firstComponentValues = firstComponentValues
		self.secondComponentValues = secondComponentValues
	}
}
