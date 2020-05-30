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

class DynamicTableViewStepCell: UITableViewCell {
	lazy var body = UILabel(frame: .zero)
	var cellIcon: UIImageView!
	var separator: UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	private func setUpView(_ title: String,
						   _ image: UIImage?,
						   _ hasSeparators: Bool = false,
						   _: Bool = false,
						   _ iconTintColor: UIColor? = nil,
						   _ iconBackgroundColor: UIColor? = nil) {
		// MARK: - Cell related changes.

		selectionStyle = .none
		backgroundColor = .preferredColor(for: .backgroundBase)

		// MARK: - Body.

		body = UILabel(frame: .zero)
		body.numberOfLines = 0
		body.lineBreakMode = .byWordWrapping
		body.text = title

		// MARK: - Cell Icon.
		var loadedImage = image
		if iconTintColor != nil {
			loadedImage = image?.withRenderingMode(.alwaysTemplate)
		}
		cellIcon = UIImageView(image: loadedImage)
		cellIcon.tintColor = iconTintColor
		cellIcon.backgroundColor = iconBackgroundColor

		// MARK: - Separator.

		separator = UIView(frame: .zero)
		separator.backgroundColor = .preferredColor(for: .chevron)
		separator.isHidden = !hasSeparators
	}

	private func setConstraints() {
		// MARK: - Constraint handling.

		UIView.translatesAutoresizingMaskIntoConstraints(for: [body,
															   cellIcon,
															   separator], to: false)

		addSubviews([separator, cellIcon, body])

		// TODO: Set the width programmatically, then calculate the
		// multiline label break afterwards.
		body.frame.size.width = 300
		body.sizeToFit()
		let height = body.frame.height
		let width = body.frame.width

		setConstraint(for: body.widthAnchor, equalTo: width)
		setConstraint(for: body.heightAnchor, equalTo: height)
		setConstraint(for: heightAnchor, equalTo: height + 50)
		setConstraint(for: cellIcon.widthAnchor, equalTo: 32)
		setConstraint(for: cellIcon.heightAnchor, equalTo: 32)
		setConstraint(for: separator.widthAnchor, equalTo: 1)

		cellIcon.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
		cellIcon.rightAnchor.constraint(equalTo: body.leftAnchor, constant: -10).isActive = true
		cellIcon.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
		// TODO: Set this programmatically.
		cellIcon.layer.cornerRadius = 16
		cellIcon.clipsToBounds = true

		let inset = cellIcon.frame.height * 0.35
		body.topAnchor.constraint(equalTo: cellIcon.topAnchor, constant: inset).isActive = true
		body.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

		separator.topAnchor.constraint(equalTo: cellIcon.bottomAnchor).isActive = true
		separator.centerXAnchor.constraint(equalTo: cellIcon.centerXAnchor).isActive = true
		separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}

	func configure(title: String,
				   image: UIImage?,
				   hasSeparators: Bool = false,
				   isCircle: Bool = false,
				   iconTintColor: UIColor? = nil,
				   iconBackgroundColor: UIColor? = nil) {
		setUpView(title, image, hasSeparators, isCircle, iconTintColor, iconBackgroundColor)
		setConstraints()
	}
}
