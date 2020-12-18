//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionStepCell: UITableViewCell {
	private static let stepNib = UINib(nibName: "ExposureSubmissionStepCellRow", bundle: nil)

	@IBOutlet var iconView: UIImageView!
	@IBOutlet var hairlineView: UIView!
	@IBOutlet var hiddenAlignmentLabel: ENALabel!
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var descriptionLabel: ENALabel!

	@IBOutlet var hairlineTopConstraint: NSLayoutConstraint!

	override func awakeFromNib() {
		super.awakeFromNib()
		
		setup()

		contentView.preservesSuperviewLayoutMargins = false
		contentView.layoutMargins.top = 0
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		titleLabel.style = .headline
		titleLabel.textColor = .enaColor(for: .textPrimary1)
	}

	func configure(title: String, description: String?, icon: UIImage?, iconTint: UIColor?, hairline: Hairline, bottomSpacing: Spacing) {
		titleLabel.text = title
		descriptionLabel.text = description
		iconView.image = icon
		iconView.tintColor = iconTint ?? self.tintColor

		descriptionLabel.isHidden = (nil == description)

		applyHairline(hairline)

		contentView.layoutMargins.bottom = bottomSpacing.rawValue
	}

	func configure(style: ENAFont, color: UIColor = .enaColor(for: .textPrimary1), title: String, icon: UIImage?, iconTint: UIColor?, hairline: Hairline, bottomSpacing: Spacing) {
		configure(title: title, description: nil, icon: icon, iconTint: iconTint, hairline: hairline, bottomSpacing: bottomSpacing)

		titleLabel.style = style.labelStyle
		titleLabel.textColor = color
	}


	func configure(bulletPoint title: String, hairline: Hairline, bottomSpacing: Spacing) {
		configure(style: .body, title: title, icon: UIImage(named: "Icons_Dark_Dot"), iconTint: nil, hairline: hairline, bottomSpacing: bottomSpacing)
	}

	
	// MARK: - Private
	
	private func applyHairline(_ hairline: Hairline) {
		switch hairline {
		case .none:
			hairlineView.isHidden = true
			hairlineTopConstraint.isActive = false
		case .topAttached:
			hairlineView.isHidden = false
			hairlineTopConstraint.isActive = true
		case .iconAttached:
			hairlineView.isHidden = false
			hairlineTopConstraint.isActive = false
		}
	}
	
	private func setup() {
		backgroundColor = .clear
	}
}

extension ExposureSubmissionStepCell {
	enum Hairline {
		case none
		case topAttached
		case iconAttached
	}

	enum Spacing: CGFloat {
		case large = 32
		case normal = 12
	}
}
