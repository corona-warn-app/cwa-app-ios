//
// 🦠 Corona-Warn-App
//

import UIKit


final class CovPassCheckInformationViewModel {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.space(height: 8),
					.body(
						text: AppStrings.HealthCertificate.Validation.body1,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: AppStrings.HealthCertificate.Validation.headline1,
						accessibilityIdentifier: ""
					)
			]),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.HealthCertificate.Validation.body4,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						}
					),
					.space(height: 16)
				]
			)
		])
	}

	// MARK: - Private
}
