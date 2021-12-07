//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewIconWithLinkTextCell: UITableViewCell {

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

		contentTextView.setContentCompressionResistancePriority(.required, for: .vertical)
		stackView.addArrangedSubview(contentTextView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
			iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
		])
	}

	// MARK: - Internal

	// swiftlint:disable function_parameter_count
	func configure(
		image: UIImage?,
		imageAlignment: DynamicCell.ImageAlignment = .left,
		text: String,
		links: [ENALinkedTextView.Link],
		customTintColor: UIColor?,
		style: ENAFont,
		iconWidth: CGFloat,
		selectionStyle: UITableViewCell.SelectionStyle,
		alignment: UIStackView.Alignment
	) {
		stackView.alignment = alignment

		iconImageView.tintColor = customTintColor ?? tintColor
		iconImageView.image = image
		iconImageView.isHidden = image == nil
		
		// swap label and image so the image is set to the right. Do this every time to get a clean reusable state.
		switch imageAlignment {
		case .left:
				stackView.removeArrangedSubview(iconImageView)
				stackView.insertArrangedSubview(iconImageView, at: 0)
	
		case .right:
				stackView.removeArrangedSubview(iconImageView)
				stackView.insertArrangedSubview(iconImageView, at: 1)
			
		}
		imageViewWidthConstraint?.constant = iconWidth
		
		contentTextView.configure(
			text: text,
			textFont: style,
			textColor: .enaColor(for: .textPrimary1),
			links: links,
			tintColor: customTintColor ?? tintColor,
			linkColor: customTintColor ?? tintColor
		)
		
		self.selectionStyle = selectionStyle
	}

	// MARK: - Private

	private var stackView = UIStackView()
	private var imageViewWidthConstraint: NSLayoutConstraint?
	private var iconImageView = UIImageView()
	private var contentTextView = ENALinkedTextView()

}
