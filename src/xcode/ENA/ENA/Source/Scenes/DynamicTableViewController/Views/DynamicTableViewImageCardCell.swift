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

class DynamicTableViewImageCardCell: UITableViewCell {

	// MARK: - View elements.

	lazy var title = ENALabel(frame: .zero)
	lazy var body = ENALabel(frame: .zero)
	lazy var cellImage = UIImageView(frame: .zero)
	lazy var chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
	lazy var insetView = UIView(frame: .zero)

	// MARK: - Constraints for resizing.
	var heightConstraint: NSLayoutConstraint?
	var insetViewHeightConstraint: NSLayoutConstraint?

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.autoresizingMask = .flexibleHeight
	}

	private func setup() {
		// MARK: - General cell setup.
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		// MARK: - Add inset view

		insetView.backgroundColor = .enaColor(for: .separator)
		insetView.layer.cornerRadius = 16.0
		insetView.clipsToBounds = true

		// MARK: - Title adjustment.

		title.style = .title2
		title.textColor = .enaColor(for: .textPrimary1)
		title.lineBreakMode = .byWordWrapping
		title.numberOfLines = 0

		// MARK: - Body adjustment.

		body.style = .body
		body.textColor = .enaColor(for: .textPrimary1)
		body.lineBreakMode = .byWordWrapping
		body.numberOfLines = 0

		// MARK: - Chevron adjustment.

		chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
		chevron.tintColor = UIColor.enaColor(for: .chevron)

		// MARK: - Image adjustment.

		cellImage.contentMode = .scaleAspectFit
	}

	private func setupConstraints() {
		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			title,
			body,
			cellImage,
			chevron,
			insetView
		], to: false)

		contentView.addSubview(insetView)
		insetView.addSubviews([
			title,
			body,
			cellImage,
			chevron
		])

		let marginGuide = contentView.layoutMarginsGuide

		insetView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
		insetView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		insetView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
		insetView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

		title.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
		title.topAnchor.constraint(equalTo: insetView.topAnchor, constant: 16).isActive = true

		chevron.widthAnchor.constraint(equalToConstant: 15).isActive = true
		chevron.heightAnchor.constraint(equalToConstant: 20).isActive = true
		chevron.leadingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
		chevron.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true
		chevron.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true

		body.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
		body.trailingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: -16).isActive = true
		body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 21).isActive = true
		insetView.bottomAnchor.constraint(greaterThanOrEqualTo: body.bottomAnchor, constant: 16).isActive = true

		cellImage.topAnchor.constraint(greaterThanOrEqualTo: chevron.bottomAnchor).isActive = true
		cellImage.trailingAnchor.constraint(equalTo: insetView.trailingAnchor).isActive = true
		cellImage.bottomAnchor.constraint(equalTo: insetView.bottomAnchor).isActive = true
		cellImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
		cellImage.heightAnchor.constraint(equalToConstant: 130).isActive = true
	}

	func configure(title: String, image: UIImage?, body: String) {
		setup()
		setupConstraints()
		self.title.text = title
		self.body.text = body
		if let image = image {
			cellImage.image = image
		}
	}

	/// This method builds a NSMutableAttributedString for the cell.
	/// - Parameters:
	///   - title: The title of the cell.
	///   - image: The image to be displayed on the right hand of the cell.
	///   - body: The text shown below the title, which should NOT be formatted in any way.
	///   - attributedStrings: The text that is injected into `body` with applied attributes, e.g.
	/// 	bold text, with color.
	func configure(title: String, image: UIImage?, body: String, attributedStrings: [NSAttributedString]) {
		setup()
		setupConstraints()
		self.title.text = title
		self.body.attributedText = NSMutableAttributedString.generateAttributedString(
			normalText: body,
			attributedText: attributedStrings
		)
		if let image = image {
			cellImage.image = image
		}
	}
}
