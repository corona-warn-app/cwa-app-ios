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
	@IBOutlet private var circleView: CircularProgressView!
	@IBOutlet private var historyLabel: UILabel!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var subtitleLabel: UILabel!

	func configure(
		progress: CGFloat,
		title: String,
		subtitle: String,
		text: String,
		colorConfigurationTuple: (UIColor, UIColor)
	) {
		titleLabel?.text = title
		subtitleLabel?.text = subtitle
		if circleView.progressBarColor != colorConfigurationTuple.0 {
			circleView.progressBarColor = colorConfigurationTuple.0
		}
		if circleView.circleColor != colorConfigurationTuple.1 {
			circleView.circleColor = colorConfigurationTuple.1
		}
		historyLabel.text = text
		circleView.progress = progress
	}
}
