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

class DynamicTableViewIconCell: UITableViewCell {

	enum Text {
		case string(String)
		case attributedString(NSAttributedString)
	}

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		imageView?.tintColor = tintColor
	}

	// MARK: - Internal

	func configure(image: UIImage?, text: Text, tintColor: UIColor?, style: ENAFont = .body, iconWidth: CGFloat, selectionStyle: UITableViewCell.SelectionStyle) {
		if let tintColor = tintColor {
			imageView?.tintColor = tintColor
			imageView?.image = image?.withRenderingMode(.alwaysTemplate)
		} else {
			imageView?.image = image?.withRenderingMode(.alwaysOriginal)
		}

		(textLabel as? ENALabel)?.style = style.labelStyle

		switch text {
		case .string(let string):
			textLabel?.text = string
		case .attributedString(let attributedString):
			textLabel?.attributedText = attributedString
		}

		imageViewWidthConstraint.constant = iconWidth

		self.selectionStyle = selectionStyle
	}

	// MARK: - Private

	@IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!

}
