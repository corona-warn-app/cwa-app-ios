//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewDoubleLabelViewCell: UITableViewCell {

	// MARK: - Init

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		resetMargins()
//		configureDynamicType()
		configure(
			text1: "",
			text2: "",
			style: .body,
			accessibilityIdentifier1: nil,
			accessibilityIdentifier2: nil,
			accessibilityTraits1: .none,
			accessibilityTraits2: .none
		)
	}
	/*
	// MARK: - Protocol DynamicTableViewTextCell
	
	func configureDynamicType(size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body) {
		labelLeft.font = UIFont.preferredFont(forTextStyle: style).scaledFont(size: size, weight: weight)
		labelRight.font = UIFont.preferredFont(forTextStyle: style).scaledFont(size: size, weight: weight)

		labelLeft.adjustsFontForContentSizeCategory = true
		labelRight.adjustsFontForContentSizeCategory = true
	}

	func configure(text: String, color: UIColor? = nil) {
		
		// set the text and color in the custom configure func because we need it for both labels
	}

	func configureAccessibility(label: String? = nil, identifier: String? = nil, traits: UIAccessibilityTraits = .staticText) {
		// set the accessibility in the custom configure func because we need it for both labels
	}
	*/
	// MARK: - Internal

	func configure(
		text1: String,
		text2: String,
		style: ENAFont,
		accessibilityIdentifier1: String?,
		accessibilityIdentifier2: String?,
		accessibilityTraits1: UIAccessibilityTraits,
		accessibilityTraits2: UIAccessibilityTraits
	) {
		labelLeft.text = text1
		labelRight.text = text2
		
		labelLeft.style = style.labelStyle
		labelRight.style = style.labelStyle
		
		labelLeft.accessibilityLabel = accessibilityIdentifier1
		labelRight.accessibilityLabel = accessibilityIdentifier2
		
		labelLeft.accessibilityTraits = accessibilityTraits1
		labelRight.accessibilityTraits = accessibilityTraits2
	}

	// MARK: - Private

	private let labelLeft = ENALabel()
	private let labelRight = ENALabel()
	
	private func setup() {
		
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)
		
		labelLeft.textAlignment = .left
		labelRight.textAlignment = .right
		
		labelLeft.translatesAutoresizingMaskIntoConstraints = false
		labelRight.translatesAutoresizingMaskIntoConstraints = false

		labelLeft.tintColor = .enaColor(for: .textTint)
		labelRight.tintColor = .enaColor(for: .textTint)

		contentView.addSubview(labelLeft)
		contentView.addSubview(labelRight)
		
		NSLayoutConstraint.activate([
			labelLeft.topAnchor.constraint(equalTo: topAnchor, constant: 2.0),
			labelLeft.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
			labelLeft.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2.0),
			labelLeft.trailingAnchor.constraint(equalTo: centerXAnchor, constant: 2.0),
			labelRight.topAnchor.constraint(equalTo: topAnchor, constant: 2.0),
			labelRight.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 2.0),
			labelRight.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2.0),
			labelRight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0)
		])
		
		resetMargins()
	}

	private func resetMargins() {
		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		contentView.insetsLayoutMarginsFromSafeArea = false
	}
}
