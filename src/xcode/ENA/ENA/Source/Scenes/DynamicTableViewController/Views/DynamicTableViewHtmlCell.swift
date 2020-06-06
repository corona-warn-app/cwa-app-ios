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

import Foundation
import UIKit

class DynamicTableViewHtmlCell: UITableViewCell {
	let textView = HtmlTextView()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	private func setup() {
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false

		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		contentView.addSubview(textView)
		contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
		contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
		contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
		contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor).isActive = true
	}
}
