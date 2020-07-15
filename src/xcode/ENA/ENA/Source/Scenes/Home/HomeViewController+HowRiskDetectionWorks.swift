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

import UIKit

extension UIAlertController {
	class func localizedHowRiskDetectionWorksAlertController(
		maximumNumberOfDays: Int
	) -> UIAlertController {
		let title = NSLocalizedString("How_Risk_Detection_Works_Alert_Title", comment: "")
		let message = String(
			format: NSLocalizedString(
				"How_Risk_Detection_Works_Alert_Message",
				comment: ""
			),
			maximumNumberOfDays
		)

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: NSLocalizedString("Alert_ActionOk", comment: ""),
				style: .default
			)
		)

		return alert
	}
}
