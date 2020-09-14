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
//

import Foundation
import XCTest
@testable import ENA

class EUSettingsCellTests: XCTestCase {

	private func makeDynamicTableViewController() -> DynamicTableViewController {
		let vc = DynamicTableViewController()
		vc.tableView.register(
			SwitchCell.self,
			forCellReuseIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.switchCell.rawValue
		)

		vc.loadViewIfNeeded()
		return vc
	}

	func testEUSwitchCell() {
		let vc = makeDynamicTableViewController()
		let model = EUSettingsViewModel.CountryModel(Country.defaultCountry())
		let cellConfigurator = DynamicCell.euSwitchCell(cellModel: model, onToggle: nil)

		guard
			let cell = vc.tableView.dequeueReusableCell(
				withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.switchCell.rawValue
			) as? SwitchCell
		else {
			XCTFail("Could not cast cell to SwitchCell")
			return
		}

		cellConfigurator.configure(cell: cell, at: IndexPath(row: 0, section: 0), for: vc)
		XCTAssertEqual(cell.textLabel?.text, model.country.localizedName)
		XCTAssertEqual(cell.imageView?.image, model.country.flag)
		XCTAssertEqual(cell.uiSwitch.isOn, false)
	}
}
