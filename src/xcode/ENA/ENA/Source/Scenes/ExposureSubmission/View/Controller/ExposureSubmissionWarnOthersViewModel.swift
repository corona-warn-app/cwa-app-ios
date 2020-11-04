import Foundation
import UIKit

struct ExposureSubmissionWarnOthersViewModel {
	
	// MARK: - Init

	init(
		supportedCountries: [Country]
	) {
		self.supportedCountries = supportedCountries.sorted { $0.localizedName.localizedCompare($1.localizedName) == .orderedAscending }
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Submission_AndereWarnen"),
						accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
						height: 250
					),
					cells: [
						.title2(
							text: AppStrings.ExposureSubmissionWarnOthers.sectionTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.sectionTitle
						),
						.body(
							text: AppStrings.ExposureSubmissionWarnOthers.description,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.description
						),
						.space(height: 16),
						.headline(
							text: AppStrings.ExposureSubmissionWarnOthers.supportedCountriesTitle,
							accessibilityIdentifier: nil
						),
						.space(height: 12)
					]
				)
			)
			$0.add(
				.section(
					separators: .inBetween,
					cells: supportedCountries.map {
						DynamicCell.icon($0.flag, text: .string($0.localizedName), iconWidth: 28) { _, cell, _ in
							cell.contentView.layoutMargins.left = 32
							cell.contentView.layoutMargins.right = 32
						}
					}
				)
			)
			$0.add(
				.section(
					cells: [
						.space(height: 20),
						.custom(
							withIdentifier: ExposureSubmissionWarnOthersViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }

								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesText
									),
									textColor: .textContrast,
									bgColor: .riskNeutral
								)
							}
						),
						.custom(
							withIdentifier: ExposureSubmissionWarnOthersViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }

								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentDescription
									),
									textColor: .textPrimary1,
									bgColor: .separator
								)
							}
						)
					]
				)
			)
		}
	}

	// MARK: - Private

	private let supportedCountries: [Country]

}
