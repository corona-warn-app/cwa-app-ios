//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum ExposureSubmissionDynamicCell {

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}

	static func stepCell(
		title: String,
		description: String?,
		icon: UIImage?,
		iconTint: UIColor? = nil,
		hairline: ExposureSubmissionStepCell.Hairline,
		bottomSpacing: ExposureSubmissionStepCell.Spacing = .large,
		action: DynamicAction = .none
	) -> DynamicCell {
		.identifier(CustomCellReuseIdentifiers.stepCell, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionStepCell else { return }
			cell.configure(title: title, description: description, icon: icon, iconTint: iconTint, hairline: hairline, bottomSpacing: bottomSpacing)
		}
	}

	static func stepCell(
		style: ENAFont,
		color: UIColor = .enaColor(for: .textPrimary1),
		title: String,
		icon: UIImage? = nil,
		iconAccessibilityLabel: String? = nil,
		accessibilityLabel: String? = nil,
		accessibilityTraits: UIAccessibilityTraits? = nil,
		iconTint: UIColor? = nil,
		hairline: ExposureSubmissionStepCell.Hairline,
		bottomSpacing: ExposureSubmissionStepCell.Spacing = .large,
		action: DynamicAction = .none
	) -> DynamicCell {
		.identifier(
			CustomCellReuseIdentifiers.stepCell,
			action: action,
			configure: { _, cell, _ in
				guard let cell = cell as? ExposureSubmissionStepCell else {
					return
				}
				cell.configure(style: style, color: color, title: title, icon: icon, iconTint: iconTint, hairline: hairline, bottomSpacing: bottomSpacing)

				cell.accessibilityLabel = accessibilityLabel
				cell.titleLabel.accessibilityLabel = [iconAccessibilityLabel, accessibilityLabel]
					.compactMap({ $0 })
					.joined(separator: ": ")

				if let accessibilityTraits = accessibilityTraits {
					cell.accessibilityTraits = accessibilityTraits
				}
			}
		)
	}

}
