//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionStepCell: UITableViewCell {
	
	var iconView: UIImageView!
	var titleLabel: ENALabel!
	var descriptionLabel: ENALabel!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.style = .headline
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		hairline = .none
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		switch hairline {
		case .none:
			break
		case .topAttached:
			hairlineView.isHidden = false
			hairlineTopConstraint.isActive = true
		case .iconAttached:
			hairlineView.isHidden = false
			hairlineTopConstraint.isActive = false
		}
	}

	func configure(title: String, description: String?, icon: UIImage?, iconTint: UIColor?, hairline: Hairline, bottomSpacing: Spacing) {
		titleLabel.text = title
		descriptionLabel.text = description
		iconView.image = icon
		iconView.tintColor = iconTint ?? self.tintColor
		self.hairline = hairline
		
		contentView.layoutMargins.bottom = bottomSpacing.rawValue
		
		if description == nil {
			descriptionLabel.isHidden = true
			NSLayoutConstraint.deactivate(descriptionLabelConstraints)
		} else {
			descriptionLabel.isHidden = false
			NSLayoutConstraint.activate(descriptionLabelConstraints)
		}
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
	
	private var hairline = Hairline.none
	private var descriptionLabelConstraints = [NSLayoutConstraint]()
	
	private func setup() {
		backgroundColor = .enaColor(for: .background)
		contentView.layoutMargins.top = 0
		// iconView
		iconView = UIImageView(image: UIImage(named: "Icons_Grey_Check"))
		iconView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(iconView)
		// titleLabel
		titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.numberOfLines = 0
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		// descriptionLabel
		descriptionLabel = ENALabel()
		descriptionLabel.style = .body
		descriptionLabel.numberOfLines = 0
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(descriptionLabel)
		// description label constraints
		descriptionLabelConstraints = [
			descriptionLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 9),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17),
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
		]
		// activate constraints
		NSLayoutConstraint.activate([
			// titleLabel constraints
			iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			iconView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -17),
			iconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			iconView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
			iconView.heightAnchor.constraint(equalToConstant: 32),
			iconView.widthAnchor.constraint(equalToConstant: 32),
			// titleLabel constraints
			titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 9),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17),
			titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
		])
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
