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

class DynamicTableViewRoundedCell: UITableViewCell {

	// MARK: - View elements.

	lazy var title = ENALabel(frame: .zero)
	lazy var body = ENALabel(frame: .zero)
	lazy var insetView = UIView(frame: .zero)
	lazy var iconStackView = UIStackView(frame: .zero)
	lazy var button = ENAButton(frame: .zero)

	// MARK: - Callbacks.

	private var buttonTapped: (() -> Void)?

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

	private func setup(titleStyle: ENALabel.Style, bodyStyle: ENALabel.Style, textColor: ENAColor, bgColor: ENAColor, icons: [UIImage], buttonTitle: String?, buttonTapped: (() -> Void)?) {

		// MARK: - General cell setup.
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		// MARK: - Add inset view
		insetView.backgroundColor = .enaColor(for: bgColor)
		insetView.layer.cornerRadius = 16.0

		// MARK: - Title adjustment.
		title.style = titleStyle
		title.textColor = .enaColor(for: textColor)
		title.lineBreakMode = .byWordWrapping
		title.numberOfLines = 0

		// MARK: - Body adjustment.
		body.style = bodyStyle
		body.textColor = .enaColor(for: textColor)
		body.lineBreakMode = .byWordWrapping
		body.numberOfLines = 0

		// MARK: - Stackview adjustment.
		if !icons.isEmpty {
			iconStackView = UIStackView(frame: .zero)
			iconStackView.axis = .horizontal
			iconStackView.spacing = 8
			iconStackView.distribution = .fillProportionally
			for icon in icons {
				iconStackView.addArrangedSubview(UIImageView(image: icon))
			}
		}

		// MARK: - Button adjustment.
		if let buttonTitle = buttonTitle {
			button.setTitle(buttonTitle, for: .normal)
			let tapHandler = UITapGestureRecognizer(target: self, action: #selector(didTapButton(sender:)))
			button.addGestureRecognizer(tapHandler)
			self.buttonTapped = buttonTapped
		}

		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			insetView, title, body, iconStackView, button
		], to: false)

		addSubview(insetView)
		insetView.addSubviews([title, body, iconStackView, button])
	}

	private func setupConstraints() {
		body.sizeToFit()
		title.sizeToFit()
		iconStackView.sizeToFit()

		let marginGuide = contentView.layoutMarginsGuide
		contentView.addSubview(insetView)
		insetView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
		insetView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		insetView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
		insetView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

		title.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
		title.topAnchor.constraint(equalTo: insetView.topAnchor, constant: 20).isActive = true

		if iconStackView.subviews.isEmpty {
			title.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true
			iconStackView.removeFromSuperview()
		} else {
			title.trailingAnchor.constraint(equalTo: iconStackView.leadingAnchor, constant: -32).isActive = true
			iconStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
			iconStackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
			iconStackView.topAnchor.constraint(equalTo: insetView.topAnchor, constant: 20).isActive = true
			iconStackView.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true
		}

		body.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
		body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16).isActive = true
		body.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true

		if buttonTapped != nil {
			body.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -37).isActive = true
			button.leadingAnchor.constraint(equalTo: insetView.leadingAnchor, constant: 16).isActive = true
			button.trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: -16).isActive = true
			button.bottomAnchor.constraint(equalTo: insetView.bottomAnchor, constant: -16).isActive = true
		} else {
			body.bottomAnchor.constraint(equalTo: insetView.bottomAnchor, constant: -16).isActive = true
			button.removeFromSuperview()
		}
	}

	func configure(
		title: NSMutableAttributedString,
		titleStyle: ENALabel.Style = .headline,
		body: NSMutableAttributedString,
		bodyStyle: ENALabel.Style = .body,
		textColor: ENAColor,
		bgColor: ENAColor,
		icons: [UIImage] = [],
		buttonTitle: String? = nil,
		buttonTapped: (() -> Void)? = nil
	) {
		setup(
			titleStyle: titleStyle,
			bodyStyle: bodyStyle,
			textColor: textColor,
			bgColor: bgColor,
			icons: icons,
			buttonTitle: buttonTitle,
			buttonTapped: buttonTapped
		)
		setupConstraints()
		self.title.attributedText = title
		self.body.attributedText = body
	}

	// MARK: - Helper methods
	@objc
	private func didTapButton(sender: UITapGestureRecognizer) {
		buttonTapped?()
	}

}
