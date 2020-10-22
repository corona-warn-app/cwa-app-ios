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
		let filename = "usage"
		let fileExtension = "html"
		
		// get the URL for de
		let url = Bundle.main.url(forResource: filename, withExtension: "html")
		var pathString = url?.deletingLastPathComponent().deletingLastPathComponent().absoluteString
		
		let anotherURL = Bundle.main.url(forResource: filename, withExtension: fileExtension, subdirectory: pathString, localization: "en")
		pathString = pathString! + "en.lproj"
		let files = Bundle.main.paths(forResourcesOfType: "html", inDirectory: pathString, forLocalization: "en")
		
		
		let data = try Data(contentsOf: url!)
		let text = String(data: data, encoding: .utf8)
		
	}

	func testUsageText() throws {
		let filename = "usage"
		let fileExtension = "html"
		
		
		let urlEN = Bundle.main.url(forResource: filename, withExtension: fileExtension)

		let dataEN = try Data(contentsOf: urlEN!.deletingLastPathComponent()
								.deletingLastPathComponent()
								.appendingPathComponent("en.lproj")
								.appendingPathComponent(filename + "." + fileExtension)
		)
		
		let textEN = try getText(filename: filename, fileExtension: fileExtension, localization: "en")
		let textPL = try getText(filename: filename, fileExtension: fileExtension, localization: "pl")
		let textRO = try getText(filename: filename, fileExtension: fileExtension, localization: "ro")
		let textBG = try getText(filename: filename, fileExtension: fileExtension, localization: "bg")

		print(textEN.count)
		print(textPL.count)
		print(textRO.count)
		print(textBG.count)
		XCTAssertEqual(textEN.count, textPL.count)
//		XCTAssertEqual(textEN, textPL)
		
	}
	
	
	private func getText(filename: String, fileExtension: String, localization: String) throws -> String {
		let directory = localization + ".lproj"
		let url = Bundle.main.url(forResource: filename, withExtension: fileExtension)
		
		let data = try Data(contentsOf: url!.deletingLastPathComponent()
								.deletingLastPathComponent()
								.appendingPathComponent(directory)
								.appendingPathComponent(filename + "." + fileExtension)
		)
		return String(data: data, encoding: .utf8) ?? ""
		
	}
	
}
