//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DynamicTableViewBulletPointCell: UITableViewCell {
	
	
	/// Spacing will get divided by two and applied to top and bottom
	enum Spacing: CGFloat {
		case large = 16
		case normal = 6
	}

	/// Bullet point alignment
	enum Alignment {
		/// Default alignment. No offset.
		case normal
		/// Adding 12 points extra alignment - FOR JUSTICE!
		case legal
		/// Custom alignment to be added to the default value.
		case custom(value: CGFloat)
	}
	
	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setUp()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal
	/// keepOriginalAttributes parameter: If you have already attributes in the attributedStrings you want to keep, you can set keepOriginalAttributes to true. This will ensure, that your attributes are not overwritten internally
	func configure(attributedString text: NSAttributedString, spacing: Spacing, alignment: Alignment = .normal, accessibilityTraits: UIAccessibilityTraits, accessibilityIdentifier: String? = nil, keepOriginalAttributes: Bool = false) {

		let bulletPointFont = text.attribute(
			.font, at: 0,
			effectiveRange: nil
		) as? UIFont ?? contentLabel.font ?? .enaFont(for: .body)
		
		contentLabel.attributedText = text.bulletPointString(
			bulletPointFont: bulletPointFont,
			keepOriginalAttributes: keepOriginalAttributes
		)
		
		self.accessibilityIdentifier = accessibilityIdentifier
		self.accessibilityTraits = accessibilityTraits
		accessibilityLabel = text.string

		bottomSpacingConstraint?.constant = -(spacing.rawValue / 2)
		topSpacingConstraint?.constant = spacing.rawValue / 2

		// adjust alignment, if needed
		switch alignment {
		case .legal:
			leadingConstraint?.constant = offset + 12
			setNeedsUpdateConstraints()
		case .custom(let value):
			leadingConstraint?.constant = offset + value
			setNeedsUpdateConstraints()
		default:
			break
		}
		layoutIfNeeded()
	}

	/// This configure will automatically set keepOriginalAttributes to true. So If you have already attributes in the attributedStrings you want to keep, you can use this configuration call. This will ensure, that your attributes are not overwritten internally
	func configure(text: String, spacing: Spacing, alignment: Alignment = .normal, accessibilityTraits: UIAccessibilityTraits, accessibilityIdentifier: String? = nil) {
		configure(
			attributedString: NSAttributedString(string: text),
			spacing: spacing,
			alignment: alignment,
			accessibilityTraits: accessibilityTraits,
			accessibilityIdentifier: accessibilityIdentifier,
			keepOriginalAttributes: true)
	}

	// MARK: - Private

	private var contentLabel = ENALabel()
	private var topSpacingConstraint: NSLayoutConstraint?
	private var bottomSpacingConstraint: NSLayoutConstraint?
	private var leadingConstraint: NSLayoutConstraint?

	/// Leading/Trailing anchor offset
	private let offset: CGFloat = 24

	private func setUp() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		contentLabel.textColor = .enaColor(for: .textPrimary1)
		contentLabel.style = .body
		contentLabel.numberOfLines = 0

		contentLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(contentLabel)
		
		bottomSpacingConstraint = contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		topSpacingConstraint = contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
		leadingConstraint = contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: offset)

		NSLayoutConstraint.activate([
			contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -offset),
			leadingConstraint,
			bottomSpacingConstraint,
			topSpacingConstraint
			].compactMap { $0 }
		)
	}
	
}
