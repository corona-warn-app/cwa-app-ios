//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import XCTest
@testable import ENA

class AppInformationLegalTextsTest: XCTestCase {
	
	func testTermsOfUse() throws {
		let filename = "privacy-policy"
		let fileExtension = "html"
		try compareText(filename, fileExtension)
	}

	func testUsageText() throws {
		let filename = "usage"
		let fileExtension = "html"
		try compareText(filename, fileExtension)
	}
	
	// MARK: - Private
	
	private let targetLocalizationIDs = ["pl", "ro", "bg"]
	private let sourceLocalizationID = "en"

	private func compareText(_ filename: String, _ fileExtension: String) throws {
		let sourceText = try getText(fromFile: filename, withExtension: fileExtension, localization: sourceLocalizationID)
		for id in targetLocalizationIDs {
			let targetText = try getText(fromFile: filename, withExtension: fileExtension, localization: "\(id)")
			XCTAssertEqual(targetText, sourceText)
		}
	}
	
	private func getText(fromFile: String, withExtension: String, localization: String) throws -> String {
		let directory = localization + ".lproj"
		guard let url = Bundle.main.url(forResource: fromFile, withExtension: withExtension) else {
			return ""
		}
		let data = try Data(contentsOf: url.deletingLastPathComponent()
								.deletingLastPathComponent()
								.appendingPathComponent(directory)
								.appendingPathComponent(fromFile + "." + withExtension)
		)
		return String(data: data, encoding: .utf8) ?? ""
	}
	
}
