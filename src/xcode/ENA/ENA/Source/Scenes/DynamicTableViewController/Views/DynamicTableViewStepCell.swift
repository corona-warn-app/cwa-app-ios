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

	// MARK: - Attributes.
	lazy var head = UILabel(frame: .zero)
	lazy var body = UILabel(frame: .zero)
	lazy var cellIcon = UIImageView(frame: .zero)
	lazy var separator = UIView(frame: .zero)

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	private func setUpView(
		_ title: String?,
		_ text: String,
		_ image: UIImage?,
		_ hasSeparators: Bool = false,
		_: Bool = false,
		_ iconTintColor: UIColor? = nil,
		_ iconBackgroundColor: UIColor? = nil
	) {
		// MARK: - Cell related changes.

		selectionStyle = .none
		backgroundColor = .preferredColor(for: .backgroundPrimary)

		// MARK: - Head.

		if let title = title {
			head.font = .preferredFont(forTextStyle: .headline)
			head.numberOfLines = 0
			head.lineBreakMode = .byWordWrapping
			head.text = title
		}

		// MARK: - Body.

		body.font = .preferredFont(forTextStyle: .body)
		body.numberOfLines = 0
		body.lineBreakMode = .byWordWrapping
		body.text = text

		// MARK: - Cell Icon.

		var loadedImage = image
		if iconTintColor != nil {
			loadedImage = image?.withRenderingMode(.alwaysTemplate)
		}
		cellIcon = UIImageView(image: loadedImage)
		cellIcon.tintColor = iconTintColor
		cellIcon.backgroundColor = iconBackgroundColor

		// MARK: - Separator.

		separator.backgroundColor = .preferredColor(for: .textPrimary2)
		separator.isHidden = !hasSeparators
	}

	// MARK: - Constraint handling.

	var heightConstraint: NSLayoutConstraint?
	private func setConstraints() {

		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			body,
			cellIcon,
			separator,
			head
		], to: false)

		addSubviews([separator, cellIcon, body, head])

		setConstraint(for: cellIcon.widthAnchor, equalTo: 32)
		setConstraint(for: cellIcon.heightAnchor, equalTo: 32)
		setConstraint(for: separator.widthAnchor, equalTo: 1)
		cellIcon.topAnchor.constraint(equalTo: topAnchor).isActive = true
		cellIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true

		head.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: 10).isActive = true
		head.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true

		if head.text != nil {
			head.topAnchor.constraint(equalTo: topAnchor).isActive = true
			body.topAnchor.constraint(equalTo: head.bottomAnchor, constant: 8).isActive = true
		} else {
			body.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
		}

		bottomAnchor.constraint(equalTo: body.bottomAnchor, constant: 8).isActive = true

		body.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: 10).isActive = true
		body.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true

		cellIcon.layer.cornerRadius = 16
		cellIcon.clipsToBounds = true

		separator.topAnchor.constraint(equalTo: cellIcon.bottomAnchor).isActive = true
		separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		separator.centerXAnchor.constraint(equalTo: cellIcon.centerXAnchor).isActive = true
	}

	func configure(
		title: String? = nil,
		text: String,
		image: UIImage?,
		hasSeparators: Bool = false,
		isCircle: Bool = false,
		iconTintColor: UIColor? = nil,
		iconBackgroundColor: UIColor? = nil
	) {
		setUpView(title, text, image, hasSeparators, isCircle, iconTintColor, iconBackgroundColor)
		setConstraints()
	}

}

// MARK: - TableViewReuseIdentifiers.

extension DynamicTableViewStepCell {
	enum ReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case cell = "dynamicTableViewStepCell"
	}

	static var tableViewCellReuseIdentifier: TableViewCellReuseIdentifiers {
		return ReuseIdentifier.cell
	}
}
