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
import UIKit

class EUSettingsViewController: DynamicTableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
	}

	private func setUp() {
		title = "### Europaweite Risiko-Ermittlung"
		view.backgroundColor = .enaColor(for: .background)

		setupTableView()
		setupBackButton()
	}

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = .euSettingsModel()
	}

}

private extension DynamicTableViewModel {
	static func euSettingsModel() -> DynamicTableViewModel {
		DynamicTableViewModel([
			.section(cells: [
				.headline(text: "### Bitte aktivieren sie alle länder in denen sie sich aufhalten oder in den letzten 14 tagen aufgehalten haben", accessibilityIdentifier: ""),
				.body(text: "### Alle Länder switch", accessibilityIdentifier: ""),
				.footnote(text: "## Die aktivierung aller länder erzeugt erhöhtes datenvolumen", accessibilityIdentifier: ""),
				.body(text: "### Alle länder switch", accessibilityIdentifier: ""),
				.footnote(text: "### Daten aus den gewählten ländern werden.... ", accessibilityIdentifier: ""),
				.body(text: "### StepCell", accessibilityIdentifier: ""),
				.body(text: "### graue box text", accessibilityIdentifier: "")
			])
		])
	}
}
