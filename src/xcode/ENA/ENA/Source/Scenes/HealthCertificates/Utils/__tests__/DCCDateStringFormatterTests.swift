////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DCCDateStringFormatterTests: XCTestCase {

	func testGIVEN_UnformattedDateOfBirth_When_Formatting_THEN_FormatIsCorrect() throws {
		for dateOfBirthFormattingTestData in dateOfBirthFormattingTestEntries {
			guard let dob = dateOfBirthFormattingTestData["dob"] else {
				XCTFail("String expected.")
				return
			}

			let formattedDOB = DCCDateStringFormatter.formattedString(from: dob)
			let expected = dateOfBirthFormattingTestData["formatted"]
			XCTAssertEqual(formattedDOB, expected)

			let localizedFormattedDOB = DCCDateStringFormatter.localizedFormattedString(from: dob)
			let expectedLocalizedFormat = dateOfBirthFormattingTestData["localized"]
			XCTAssertEqual(localizedFormattedDOB, expectedLocalizedFormat)
		}
	}

	let dateOfBirthFormattingTestEntries = [
		[
			"dob": "1964-08-12",
			"formatted": "1964-08-12",
			"localized": "12.08.1964"
		],
		[
			"dob": "1964-08",
			"formatted": "1964-08",
			"localized": "08.1964"
		],
		[
			"dob": "1964",
			"formatted": "1964",
			"localized": "1964"
		],
		[
			"dob": "",
			"formatted": "",
			"localized": ""
		],
		[
			"dob": "1978-01-26T00:00:00",
			"formatted": "1978-01-26",
			"localized": "26.01.1978"
		],
		[
			"dob": "lorem-ipsum",
			"formatted": "lorem-ipsum",
			"localized": "lorem-ipsum"
		],
		[
			"dob": "1964-08-12",
			"formatted": "1964-08-12",
			"localized": "12.08.1964"
		],
		[
			"dob": "1978-01-26T00:00:00",
			"formatted": "1978-01-26",
			"localized": "26.01.1978"
		],
		[
			"dob": "2021-03-18T15:31:00+02:00",
			"formatted": "2021-03-18",
			"localized": "18.03.2021"
		]
	]

}
