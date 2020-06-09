//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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
//

import Foundation
import UIKit

private extension DynamicCell {
	static func legal(title: String, licensor: String, fullLicense: String) -> Self {
		.identifier(AppInformationDetailViewController.CellReuseIdentifier.legal) { _, cell, _ in
			guard let cell = cell as? AppInformationLegalCell else { return }
			cell.titleLabel.text = title
			cell.licensorLabel.text = licensor
			cell.licenseLabel.text = fullLicense
		}
	}
}

func readLicensePropertyList() -> [DynamicCell] {
	var legalCells: [DynamicCell] = []
	guard
		let path = Bundle.main.path(forResource: "THIRD-PARTY-LICENSE-INFO", ofType: "plist"),
		let xml = FileManager.default.contents(atPath: path),
		let plistDict = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainers, format: nil) as? [String: [[String: String]]]

	else {
		return legalCells
	}
	
	guard let licenseArray = plistDict["licenses"] else {
		return legalCells
	}
	
	for licenseDict in licenseArray {
		guard
			let title = licenseDict["component"],
			let licensor = licenseDict["licensor"],
			let fullLicense = licenseDict["fullLicense"]
		else {
			return legalCells
		}
		legalCells.append(DynamicCell.legal(title: title, licensor: licensor, fullLicense: fullLicense))
	}

	return legalCells

}

extension AppInformationViewController {
	static let legalModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_RechtlicheHinweise"),
						   accessibilityLabel: AppStrings.AppInformation.legalImageDescription,
						   height: 230),
			cells: legalCells
		)
	])

	private static let legalCells: [DynamicCell] = readLicensePropertyList()

}
