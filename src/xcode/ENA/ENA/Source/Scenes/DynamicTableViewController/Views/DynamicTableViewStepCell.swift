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
	lazy var head = ENALabel(frame: .zero)
	lazy var body = ENALabel(frame: .zero)
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
			head.style = .headline
			head.textColor = .preferredColor(for: .textPrimary1)
			head.numberOfLines = 0
			head.lineBreakMode = .byWordWrapping
			head.text = title
		}

		// MARK: - Body.

		body.textColor = .preferredColor(for: .textPrimary1)
		body.style = .body
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

	private func setUpView(
		_ attributedText: NSMutableAttributedString,
		_ image: UIImage?,
		_ hasSeparators: Bool = false,
		_: Bool = false,
		_ iconTintColor: UIColor? = nil,
		_ iconBackgroundColor: UIColor? = nil
	) {
		// MARK: - Cell related changes.

		selectionStyle = .none
		backgroundColor = .preferredColor(for: .backgroundPrimary)

		// MARK: - Body.

		body.font = .preferredFont(forTextStyle: .body)
		body.numberOfLines = 0
		body.lineBreakMode = .byWordWrapping
		body.attributedText = attributedText

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
			head.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
			body.topAnchor.constraint(equalTo: head.bottomAnchor, constant: 8).isActive = true
		} else {
			body.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
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

	/// Default configurator for a DynamicStepCell.
	/// - Parameters:
	///   - text: The text shown in the cell which should NOT be formatted in any way.
	///   - attributedText: The text that is injected into `body` with applied attributes, e.g.
	/// 	bold text, with color.
	///   - image: The image to be displayed on the right hand of the cell.
	///   - hasSeparators: boolean that indicates whether the cell has a grey
	///     separator or not.
	///   - isCircle: boolean indicating whether the icon of the cell is circular or not.
	///   - iconTintColor: tintColor for the icon of the cell.
	///   - iconBackgroundColor: background color for the icon of the cell.
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

	/// Configurator for a DynamicStepCell that supports NSAttributedStrings.
	/// - Parameters:
	///   - text: The text shown in the cell which should NOT be formatted in any way.
	///   - attributedText: The text that is injected into `body` with applied attributes, e.g.
	/// 	bold text, with color.
	///   - image: The image to be displayed on the right hand of the cell.
	///   - hasSeparators: boolean that indicates whether the cell has a grey
	///     separator or not.
	///   - isCircle: boolean indicating whether the icon of the cell is circular or not.
	///   - iconTintColor: tintColor for the icon of the cell.
	///   - iconBackgroundColor: background color for the icon of the cell.
	func configure(
		text: String,
		attributedText: [NSAttributedString],
		image: UIImage?,
		hasSeparators: Bool = false,
		isCircle: Bool = false,
		iconTintColor: UIColor? = nil,
		iconBackgroundColor: UIColor? = nil
	) {

		setUpView(NSMutableAttributedString.generateAttributedString(
					  normalText: text,
					  attributedText: attributedText
				  ),
				  image,
				  hasSeparators,
				  isCircle,
				  iconTintColor
		)
		
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
