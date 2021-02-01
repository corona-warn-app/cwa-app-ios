//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewIconCell: UITableViewCell {

	// MARK: - Init

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		backgroundColor = .enaColor(for: .background)

		stackView.axis = .horizontal
		stackView.spacing = 16

		contentView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		imageViewWidthConstraint = iconImageView.widthAnchor.constraint(equalToConstant: 32)
		imageViewWidthConstraint?.isActive = true

		stackView.addArrangedSubview(iconImageView)

		contentTextLabel.style = .body
		contentTextLabel.adjustsFontForContentSizeCategory = true
		contentTextLabel.textColor = .enaColor(for: .textPrimary1)
		contentTextLabel.numberOfLines = 0
		contentTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		stackView.addArrangedSubview(contentTextLabel)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
			iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
		])
	}

	// MARK: - Overrides

	override var textLabel: UILabel? {
		contentTextLabel
	}

	override var imageView: UIImageView? {
		iconImageView
	}

	// MARK: - Internal

	enum Text {
		case string(String)
		case attributedString(NSAttributedString)
	}

	func configure(
		image: UIImage?,
		text: Text,
		customTintColor: UIColor?,
		style: ENAFont,
		iconWidth: CGFloat,
		selectionStyle: UITableViewCell.SelectionStyle,
		alignment: UIStackView.Alignment
	) {
		stackView.alignment = alignment

		if let customTintColor = customTintColor {
			iconImageView.tintColor = customTintColor
			iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
		} else {
			iconImageView.tintColor = tintColor
			iconImageView.image = image?.withRenderingMode(.alwaysOriginal)
		}

		iconImageView.isHidden = image == nil

		imageViewWidthConstraint?.constant = iconWidth

		contentTextLabel.style = style.labelStyle

		switch text {
		case .string(let string):
			contentTextLabel.text = string
		case .attributedString(let attributedString):
			contentTextLabel.attributedText = attributedString
		}

		self.selectionStyle = selectionStyle
	}

	// MARK: - Private

	private var stackView = UIStackView()
	private var imageViewWidthConstraint: NSLayoutConstraint?
	private var iconImageView = UIImageView()
	private var contentTextLabel = ENALabel()

}
