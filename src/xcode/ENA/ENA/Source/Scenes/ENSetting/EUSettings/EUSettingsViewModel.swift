//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

class EUSettingsViewModel {

	// MARK: - Init

	init(countries availableCountries: [Country] = []) {
		self.countries = availableCountries.sortedByLocalizedName
	}

	// MARK: - Internal

	let countries: [Country]

	func euSettingsModel() -> DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .image(UIImage(named: "Illu_EU_Interop"),
							   accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
							   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
							   height: 250),
				cells: [
					.space(height: 8),
					.title1(
						text: AppStrings.ExposureNotificationSetting.euTitle,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.body(text: AppStrings.ExposureNotificationSetting.euDescription1,
						  accessibilityIdentifier: ""
					),
					.space(height: 8),
					.body(text: AppStrings.ExposureNotificationSetting.euDescription2,
						  accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: AppStrings.ExposureNotificationSetting.euDescription3,
						accessibilityIdentifier: ""
					),
					.space(height: 16)

			]),
			// country flags and names if available
			.section(
				separators: countries.isEmpty ? .none : .all,
				cells:
					countries.isEmpty
					? [.emptyCell()]
					: [.countries(countries: countries)]
			),
			.section(
				cells: [
					.space(height: 8),
					.body(text: AppStrings.ExposureNotificationSetting.euDescription4,
						  accessibilityIdentifier: ""
					),
					.space(height: 16)
			])
		])
	}
}

private extension DynamicCell {

	static func emptyCell() -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.roundedCell,
			action: .none,
			accessoryAction: .none) { _, cell, _ in
				if let roundedCell = cell as? DynamicTableViewRoundedCell {
					roundedCell.configure(
						title: NSMutableAttributedString(string: AppStrings.ExposureNotificationSetting.euEmptyErrorTitle),
						titleStyle: .title2,
						body: NSMutableAttributedString(string: AppStrings.ExposureNotificationSetting.euEmptyErrorDescription),
						textColor: .textPrimary1,
						bgColor: .separator,
						icons: [
							UIImage(named: "Icons_MobileDaten"),
							UIImage(named: "Icon_Wifi")]
							.compactMap { $0 },
						buttonTitle: AppStrings.ExposureNotificationSetting.euEmptyErrorButtonTitle) {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}
				}
			}
	}
}
