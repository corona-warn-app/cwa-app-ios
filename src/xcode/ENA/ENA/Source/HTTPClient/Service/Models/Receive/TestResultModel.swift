//
// 🦠 Corona-Warn-App
//
struct TestResultModel: Codable {
	let testResult: Int
	let sc: Int?
	let labId: String?

	static func fake(
		testResult: Int = 0,
		sc: Int? = nil,
		labId: String? = nil
	) -> TestResultModel {
		TestResultModel(
			testResult: testResult,
			sc: sc,
			labId: labId
		)
	}
}
