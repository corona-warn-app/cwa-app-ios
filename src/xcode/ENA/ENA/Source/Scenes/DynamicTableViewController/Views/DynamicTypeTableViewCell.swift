//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTypeTableViewCell: UITableViewCell, DynamicTableViewTextCell {
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	private func setup() {
		selectionStyle = .none

		backgroundColor = .enaColor(for: .background)

		if let label = textLabel {
			label.translatesAutoresizingMaskIntoConstraints = false
			label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
			label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
			label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
			label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
		}

		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		accessoryType = .none
		accessoryView = nil
		selectionStyle = .none
		
		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	private func resetMargins() {
		contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		contentView.insetsLayoutMarginsFromSafeArea = false
	}

	func configureDynamicType(size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body) {
		textLabel?.font = UIFont.preferredFont(forTextStyle: style).scaledFont(size: size, weight: weight)
		textLabel?.adjustsFontForContentSizeCategory = true
		textLabel?.numberOfLines = 0
	}

	func configure(text: String, color: UIColor? = nil) {
		textLabel?.text = text
		textLabel?.textColor = color ?? .enaColor(for: .textPrimary1)
	}

	func configureAccessibility(label: String? = nil, identifier: String? = nil, traits: UIAccessibilityTraits = .staticText) {
		textLabel?.accessibilityLabel = label
		accessibilityIdentifier = identifier
		accessibilityTraits = traits
	}
}
