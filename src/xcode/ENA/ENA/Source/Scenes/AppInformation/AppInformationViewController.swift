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

class AppInformationViewController: UITableViewController {
	
	@IBOutlet weak var labelVersion: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateVersionLabel()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
		let destination = segue.destination

		guard
			let segueIdentifier = segue.identifier,
			let segue = SegueIdentifier(rawValue: segueIdentifier)
		else { return }

		switch segue {
		case .about:
			(destination as? AppInformationDetailViewController)?.model = .about
		case .contact:
			(destination as? AppInformationDetailViewController)?.model = .contact
		case .help:
			(destination as? AppInformationHelpViewController)?.model = .questions
		case .legal:
			(destination as? AppInformationDetailViewController)?.model = .legal
		case .privacy:
			(destination as? AppInformationDetailViewController)?.model = .privacy
		case .terms:
			(destination as? AppInformationDetailViewController)?.model = .terms
		}
	}
	
	func updateVersionLabel() {
		guard let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] else { return }
		guard let bundleBuild = Bundle.main.infoDictionary?["CFBundleVersion"] else { return }
		
		self.labelVersion.text = "\(AppStrings.Home.appInformationVersion) \(bundleVersion) (\(bundleBuild))"
	}
}

extension AppInformationViewController {
	private enum SegueIdentifier: String {
		case about = "aboutSegue"
		case contact = "contactSegue"
		case legal = "legalSegue"
		case privacy = "privacySegue"
		case terms = "termsSegue"
		case help = "helpSegue"
	}
}
