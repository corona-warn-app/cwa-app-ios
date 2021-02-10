//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DescriptionTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	
	private var titleLabel: ENALabel!
	private var label1: ENALabel!
	private var label2: ENALabel!
	private var label3: ENALabel!
	private var label4: ENALabel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// titleLabel
		titleLabel = ENALabel()
		titleLabel.style = .title2
		titleLabel.numberOfLines = 0
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		// label1
		label1 = ENALabel()
		label1.style = .headline
		label1.numberOfLines = 0
		label1.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label1)
		// label2
		label2 = ENALabel()
		label2.style = .subheadline
		label2.numberOfLines = 0
		label2.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label2)
		// label3
		label3 = ENALabel()
		label3.style = .subheadline
		label3.numberOfLines = 0
		label3.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label3)
		// label4
		label4 = ENALabel()
		label4.style = .subheadline
		label4.numberOfLines = 0
		label4.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label4)
		// activate constrinats
		NSLayoutConstraint.activate([
			// titleLabel
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// label1
			label1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			label1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			label1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
			label1.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// label2
			label2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			label2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 20),
			label2.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// label3
			label3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			label3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 20),
			label3.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// label4
			label4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			label4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			label4.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 20),
			label4.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(for riskDetectionState: ENStateHandler.State) {
		if riskDetectionState == .disabled {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitleInactive
		} else {
			titleLabel.text = AppStrings.ExposureNotificationSetting.descriptionTitle
		}
		label1.text = AppStrings.ExposureNotificationSetting.descriptionText1
		label2.text = AppStrings.ExposureNotificationSetting.descriptionText2
		label3.text = AppStrings.ExposureNotificationSetting.descriptionText3
		label4.text = AppStrings.ExposureNotificationSetting.descriptionText4

		titleLabel.isAccessibilityElement = true
		label1.isAccessibilityElement = true
		label2.isAccessibilityElement = true
		label3.isAccessibilityElement = true
		label4.isAccessibilityElement = true

		titleLabel.accessibilityIdentifier = (riskDetectionState == .disabled) ?
			AccessibilityIdentifiers.ExposureNotificationSetting.descriptionTitleInactive : AccessibilityIdentifiers.ExposureNotificationSetting.descriptionTitle
		label1.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText1
		label2.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText2
		label3.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText3
		label4.accessibilityIdentifier = AccessibilityIdentifiers.ExposureNotificationSetting.descriptionText4

		titleLabel.accessibilityTraits = .header
		label1.accessibilityTraits = .staticText
		label2.accessibilityTraits = .staticText
		label3.accessibilityTraits = .staticText
		label4.accessibilityTraits = .staticText
	}
}
