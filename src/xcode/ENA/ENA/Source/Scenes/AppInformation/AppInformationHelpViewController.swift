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
import UIKit

class AppInformationHelpViewController: UITableViewController {
	var model: AppInformationHelpModel!

	override func numberOfSections(in _: UITableView) -> Int {
		model.numberOfSections
	}

	override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		model.title(for: section)
	}

	override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		model.questions(in: section).count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let question = model.question(indexPath.row, in: indexPath.section)

		let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.question.rawValue, for: indexPath)

		cell.textLabel?.text = question.title

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
		let destination = segue.destination

		guard
			let segueIdentifier = segue.identifier,
			let segue = SegueIdentifier(rawValue: segueIdentifier)
		else { return }

		switch segue {
		case .detail:
			(destination as? AppInformationDetailViewController)?.model = .helpTracing
		}
	}
}

extension AppInformationHelpViewController {
	enum SegueIdentifier: String {
		case detail = "detailSegue"
	}
}

extension AppInformationHelpViewController {
	fileprivate enum ReusableCellIdentifier: String {
		case question = "questionCell"
	}
}
