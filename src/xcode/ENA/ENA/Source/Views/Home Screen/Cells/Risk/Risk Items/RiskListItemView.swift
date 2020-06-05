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

import UIKit

final class RiskListItemView: UIView, RiskItemView {

	@IBOutlet var dotLabel: ENALabel!
	@IBOutlet var textLabel: ENALabel!
	@IBOutlet var stackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		let containerInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 0.0)
		stackView.layoutMargins = containerInsets
		stackView.isLayoutMarginsRelativeArrangement = true
		configureStackView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureStackView()
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			dotLabel.isHidden = true
		} else {
			dotLabel.isHidden = false
		}
	}
}
