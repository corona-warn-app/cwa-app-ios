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
	var title: UILabel!
	var body: UILabel!
	var cellImage: UIImageView!
	var chevron: UIImageView!
	var insetView: UIView!

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
		addConstraints()
	}

	private func setup() {
		// MARK: - General cell setup.

		selectionStyle = .none
		backgroundColor = .preferredColor(for: .backgroundBase)

		// MARK: - Add inset view

		insetView = UIView(frame: .zero)
		insetView.backgroundColor = .preferredColor(for: .backgroundContrast)
		insetView.layer.cornerRadius = 16.0

		// MARK: - Title adjustment.

		title = UILabel(frame: .zero)
		title.font = UIFont.boldSystemFont(ofSize: 22)

		// MARK: - Body adjustment.

		body = UILabel(frame: .zero)
		body.font = body.font.withSize(15)
		body.lineBreakMode = .byWordWrapping
		body.numberOfLines = 0

		// MARK: - Chevron adjustment.

		chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
		chevron.tintColor = UIColor.preferredColor(for: .textPrimary2)

		// MARK: - image adjustment.

		cellImage = UIImageView(image: UIImage(named: "Hand_with_phone"))
	}

	private func addConstraints() {
		contentView.heightAnchor.constraint(equalToConstant: 196).isActive = true
		UIView.translatesAutoresizingMaskIntoConstraints(for: [contentView,
															   title,
															   body,
															   cellImage,
															   chevron,
															   insetView], to: false)

		contentView.addSubview(insetView)
		insetView.addSubviews([title,
							   body,
							   cellImage,
							   chevron])

		// TODO: Refactor rest to use setConstraint.
		setConstraint(for: insetView.widthAnchor, equalTo: 343)
		insetView.heightAnchor.constraint(equalToConstant: 172).isActive = true

		title.widthAnchor.constraint(equalToConstant: 301).isActive = true
		title.heightAnchor.constraint(equalToConstant: 28).isActive = true

		body.widthAnchor.constraint(equalToConstant: 156).isActive = true
		body.heightAnchor.constraint(equalToConstant: 80).isActive = true

		cellImage.widthAnchor.constraint(equalToConstant: 128).isActive = true
		cellImage.heightAnchor.constraint(equalToConstant: 120).isActive = true

		chevron.widthAnchor.constraint(equalToConstant: 15).isActive = true
		chevron.heightAnchor.constraint(equalToConstant: 20).isActive = true

		insetView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		insetView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

		title.topAnchor.constraint(equalTo: insetView.topAnchor, constant: 16).isActive = true
		title.leftAnchor.constraint(equalTo: insetView.leftAnchor, constant: 15).isActive = true

		body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 23).isActive = true
		body.leftAnchor.constraint(equalTo: insetView.leftAnchor, constant: 15).isActive = true

		chevron.leftAnchor.constraint(equalTo: title.rightAnchor, constant: -2).isActive = true
		chevron.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true

		cellImage.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
		cellImage.leftAnchor.constraint(equalTo: body.rightAnchor, constant: 10).isActive = true
	}

	func configure(title: String, image: UIImage?, body: String) {
		self.title.text = title
		self.body.text = body
		if let image = image {
			cellImage.image = image
		}
	}
}
