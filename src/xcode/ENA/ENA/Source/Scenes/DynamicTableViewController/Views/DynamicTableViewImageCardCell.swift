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

	lazy var title = UILabel(frame: .zero)
	lazy var body = UILabel(frame: .zero)
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
		backgroundColor = .preferredColor(for: .backgroundPrimary)

		// MARK: - Add inset view

		insetView.backgroundColor = .preferredColor(for: .backgroundSecondary)
		insetView.layer.cornerRadius = 16.0

		// MARK: - Title adjustment.

		title.font = .preferredFont(forTextStyle: .headline)
		title.lineBreakMode = .byWordWrapping
		title.numberOfLines = 0

		// MARK: - Body adjustment.

		body.font = .preferredFont(forTextStyle: .body)
		body.lineBreakMode = .byWordWrapping
		body.numberOfLines = 0

		// MARK: - Chevron adjustment.

		chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
		chevron.tintColor = UIColor.preferredColor(for: .textPrimary2)
	}

	override func updateConstraints() {
		layoutIfNeeded()
		heightConstraint?.constant = calculateHeight()
		insetViewHeightConstraint?.constant = calculateHeight() - 32
		super.updateConstraints()
		layoutIfNeeded()
	}

	/// This method calculates the height for the entire cell, depending on its content.
	private func calculateHeight() -> CGFloat {
		body.sizeToFit()
		title.sizeToFit()
		return max((64 + 21 + body.frame.height + title.frame.height), 196)
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

		heightConstraint = contentView.heightAnchor.constraint(equalToConstant: calculateHeight())
		heightConstraint?.isActive = true

		insetViewHeightConstraint = insetView.heightAnchor.constraint(equalToConstant: calculateHeight() - 32)
		insetViewHeightConstraint?.isActive = true

		chevron.widthAnchor.constraint(equalToConstant: 15).isActive = true
		chevron.heightAnchor.constraint(equalToConstant: 20).isActive = true

		insetView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
		insetView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

		title.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
		title.topAnchor.constraint(equalTo: insetView.topAnchor, constant: 16).isActive = true

		chevron.leadingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
		chevron.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true
		chevron.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true

		body.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
		body.trailingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: -16).isActive = true
		body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 21).isActive = true
		body.bottomAnchor.constraint(equalTo: insetView.bottomAnchor, constant: -16).isActive = true

		cellImage.trailingAnchor.constraint(equalTo: insetView.trailingAnchor).isActive = true
		cellImage.bottomAnchor.constraint(equalTo: insetView.bottomAnchor).isActive = true
		cellImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
		cellImage.heightAnchor.constraint(equalToConstant: 130).isActive = true
		insetView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
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

	/// TODO: Comment me!
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

// TODO: Move me!
extension NSMutableAttributedString {

	// TODO: Comment!!
	static func generateAttributedString(normalText: String, attributedText: [NSAttributedString]) -> NSMutableAttributedString {

		let components = normalText.components(separatedBy: "%@")
		let adjusted: NSMutableAttributedString = NSMutableAttributedString(string: "")

		for (index, element) in components.enumerated() {
			adjusted.append(NSAttributedString(string: element))
			if index < attributedText.count {
				adjusted.append(attributedText[index])
			}
		}

		return adjusted
	}
}
