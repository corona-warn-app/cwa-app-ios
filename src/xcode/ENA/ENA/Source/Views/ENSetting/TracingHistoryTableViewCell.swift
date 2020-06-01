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

class TracingHistoryTableViewCell: UITableViewCell {
	typealias ColorConfiguration = (progressBarColor: UIColor, circleColor: UIColor)

	@IBOutlet var circleView: CircularProgressView!
	@IBOutlet var historyTextView: UITextView!

	func configure(progress: CGFloat, text: String, colorConfigurationTuple: ColorConfiguration) {
		if circleView.progressBarColor != colorConfigurationTuple.progressBarColor {
			circleView.progressBarColor = colorConfigurationTuple.progressBarColor
		}
		if circleView.circleColor != colorConfigurationTuple.circleColor {
			circleView.circleColor = colorConfigurationTuple.circleColor
		}
		historyTextView.text = text
		circleView.progress = progress
	}
}
