////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DCCDateStringFormatterTests: XCTestCase {

	func testGIVEN_UnformattedDateOfBirth_When_Formatting_THEN_FormatIsCorrect() throws {
		for dateOfBirthFormattingTestData in dateOfBirthFormattingTestDatas {
			guard let dob = dateOfBirthFormattingTestData["dob"] else {
				XCTFail("String expected.")
				return
			}
			let formattedDOB = DCCDateStringFormatter.formatedString(from: dob)
			let expected = dateOfBirthFormattingTestData["formatted"]
			XCTAssertEqual(formattedDOB, expected)
		}
	}

	let dateOfBirthFormattingTestDatas = [
		[
			"dob": "1964-08-12",
			"formatted": "1964-08-12"
		],
		[
			"dob": "1964-08",
			"formatted": "1964-08"
		],
		[
			"dob": "1964",
			"formatted": "1964"
		],
		[
			"dob": "",
			"formatted": ""
		],
		[
			"dob": "1978-01-26T00:00:00",
			"formatted": "1978-01-26"
		],
		[
			"dob": "lorem-ipsum",
			"formatted": "lorem-ipsum"
		],
		[
			"dob": "1964-08-12",
			"formatted": "1964-08-12"
		],
		[
			"dob": "1978-01-26T00:00:00",
			"formatted": "1978-01-26"
		],
		[
			"dob": "2021-03-18T15:31:00+02:00",
			"formatted": "2021-03-18"
		]
	]

}
