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

class AppInformationModelTest: XCTestCase {
	
	private let targetLocalizationIDs = ["pl", "ro", "bg"]
	private let sourceLocalizationID = "en"
	
	func testAboutModel() {
		let dynamicTable = AppInformationModel.aboutModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.aboutModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 4)
	}

	func testContactModel() {
		let dynamicTable = AppInformationModel.contactModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.contactModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 6)
	}

	func testPrivacyModel() {
		let dynamicTable = AppInformationModel.privacyModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.privacyModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 2)
	}

	func testTermsModel() {
		let dynamicTable = AppInformationModel.termsModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.termsModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 2)
	}
	
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
	
	fileprivate func compareText(_ filename: String, _ fileExtension: String) throws {
		let sourceText = try getText(fromFile: filename, withExtension: fileExtension, localization: sourceLocalizationID)
		for id in targetLocalizationIDs {
			let targetText = try getText(fromFile: filename, withExtension: fileExtension, localization: "\(id)")
			XCTAssertEqual(sourceText, targetText)
		}
	}
	
	fileprivate func getText(fromFile: String, withExtension: String, localization: String) throws -> String {
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
