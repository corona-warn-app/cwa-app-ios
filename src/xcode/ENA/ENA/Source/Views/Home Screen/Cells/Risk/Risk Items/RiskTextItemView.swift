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

import UIKit

final class RiskTextItemView: UIView, RiskItemView, RiskItemViewSeparatorable {
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var separatorView: UIView!

	private let titleTopPadding: CGFloat = 8.0

	override func awakeFromNib() {
		super.awakeFromNib()
		layoutMargins = .init(top: titleTopPadding, left: 0, bottom: titleTopPadding, right: 0)
	}

	func hideSeparator() {
		separatorView.isHidden = true
	}
}
