//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTypeTableViewCell: UITableViewCell, DynamicTableViewTextCell {

	// MARK: - Init

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
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

	// MARK: - Internal

	func configureDynamicType(size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body) {
		contentTextLabel.font = UIFont.preferredFont(forTextStyle: style).scaledFont(size: size, weight: weight)
		contentTextLabel.adjustsFontForContentSizeCategory = true
		contentTextLabel.lineBreakMode = .byTruncatingTail
		contentTextLabel.numberOfLines = 4
	}

	func configure(text: String, color: UIColor? = nil) {
		contentTextLabel.text = text
		contentTextLabel.textColor = color ?? .enaColor(for: .textPrimary1)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
		contentTextLabel.addGestureRecognizer(tapGestureRecognizer)
		contentTextLabel.isUserInteractionEnabled = true
		contentTextLabel.isAccessibilityElement = true
	}

	func configureAccessibility(label: String? = nil, identifier: String? = nil, traits: UIAccessibilityTraits = .staticText) {
		contentTextLabel.accessibilityLabel = label
		contentTextLabel.isAccessibilityElement = true
		accessibilityIdentifier = identifier
		accessibilityTraits = traits
	}

	// MARK: - Internal

	/// better use a self create label instead of textLabel from the default UITableViewCell -> that leads to some strange layout issues
	var contentTextLabel = UILabel()

	// MARK: - Private

	private func setup() {
		selectionStyle = .none

		backgroundColor = .enaColor(for: .background)

		contentTextLabel.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(contentTextLabel)

		NSLayoutConstraint.activate([
			contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: contentTextLabel.topAnchor),
			contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: contentTextLabel.bottomAnchor),
			contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: contentTextLabel.leadingAnchor),
			contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: contentTextLabel.trailingAnchor)
		])

		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	private func resetMargins() {
		contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		contentView.insetsLayoutMarginsFromSafeArea = false
	}
	
	@objc
	private func labelTapped() {
		contentTextLabel.adjustsFontSizeToFitWidth = true
		contentTextLabel.numberOfLines = 0
	}
}
