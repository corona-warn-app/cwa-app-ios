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

class DynamicTypeTableViewCell: UITableViewCell {
	var textStyle: UIFont.TextStyle? { nil }
	var fontSize: CGFloat? { nil }
	var fontWeight: UIFont.Weight? { nil }

	required init?(coder _: NSCoder) {
		fatalError("Not implemented!")
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		selectionStyle = .none

		setupTextLabel()

		backgroundColor = .preferredColor(for: .backgroundPrimary)
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setupTextLabel()
	}

	private func setupTextLabel() {
		if let textStyle = self.textStyle {
			textLabel?.font = UIFont.preferredFont(forTextStyle: textStyle).scaledFont(size: fontSize, weight: fontWeight)
			textLabel?.adjustsFontForContentSizeCategory = true
			textLabel?.numberOfLines = 0
		}
	}
}

extension DynamicTypeTableViewCell {
	class Regular: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .body }
		override var fontSize: CGFloat? { 17 }
		override var fontWeight: UIFont.Weight? { .regular }
	}

	class Semibold: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .body }
		override var fontSize: CGFloat? { 17 }
		override var fontWeight: UIFont.Weight? { .semibold }
	}

	class Bold: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .body }
		override var fontSize: CGFloat? { 17 }
		override var fontWeight: UIFont.Weight? { .bold }
	}

	class BigBold: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .headline }
		override var fontSize: CGFloat? { 22 }
		override var fontWeight: UIFont.Weight? { .bold }
	}
}
