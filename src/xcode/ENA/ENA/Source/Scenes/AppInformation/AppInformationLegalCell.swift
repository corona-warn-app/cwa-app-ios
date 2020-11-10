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

import Foundation
import UIKit

class AppInformationLegalCell: UITableViewCell {
	var titleLabel = ENALabel()
	var licensorLabel = ENALabel()
	var licenseLabel = ENALabel()

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		separatorInset = .zero

		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.style = .body
		titleLabel.numberOfLines = 0
		licensorLabel.textColor = .enaColor(for: .textPrimary1)
		licensorLabel.style = .subheadline
		licensorLabel.numberOfLines = 0
		licenseLabel.textColor = .enaColor(for: .textPrimary1)
		licenseLabel.style = .footnote
		licenseLabel.numberOfLines = 0

		let stackView = UIStackView(arrangedSubviews: [titleLabel, licensorLabel, licenseLabel])
		stackView.axis = .vertical
		stackView.spacing = 4

		contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		contentView.addSubview(stackView)
		contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
		contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
		contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
		contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true

		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			titleLabel,
			licensorLabel,
			licenseLabel,
			stackView
		], to: false)
	}
}
