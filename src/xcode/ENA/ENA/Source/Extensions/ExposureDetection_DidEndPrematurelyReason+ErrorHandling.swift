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

extension ExposureDetection.DidEndPrematurelyReason {
	func errorAlertController(rootController: UIViewController) -> UIAlertController? {
		guard case let ExposureDetection.DidEndPrematurelyReason.noSummary(error) = self else {
			return nil
		}
		guard error != nil else {
			return nil
		}
		let alert = UIAlertController(
			title: AppStrings.ExposureDetectionError.errorAlertTitle,
			message: error?.localizedDescription ?? "",
			preferredStyle: .alert
		)
		let okAction = UIAlertAction(title: AppStrings.Common.alertActionOk, style: .default, handler: nil)
		alert.addAction(okAction)
		return alert
	}
}
