//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DeltaOnboardingV15ViewModel {
	
	// MARK: - Init

	init(
		supportedCountries: [Country]
	) {
		self.supportedCountries = supportedCountries.sortedByLocalizedName
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_EUTracingOnboarding"),
						accessibilityLabel: AppStrings.DeltaOnboarding.accImageLabel,
						accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.accImageDescription,
						height: 250
					),
					cells: [
						.title2(
							text: AppStrings.DeltaOnboarding.title,
							accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.sectionTitle
						),
						.body(
							text: AppStrings.DeltaOnboarding.description,
							accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.description
						),
						.space(height: 16)
					]
				)
			)
			$0.add(
				.section(
					separators: .none,
					cells: buildCountryCells()
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
							withIdentifier: DeltaOnboardingV15ViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }

								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.DeltaOnboarding.legalDataProcessingInfoTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.DeltaOnboarding.legalDataProcessingInfoContent
									),
									textColor: .textPrimary1,
									bgColor: .separator
								)
							}
						),
						.space(height: 8),
						.body(text: AppStrings.DeltaOnboarding.termsDescription1)
					]
				)
			)
			$0.add(
				.section(
					separators: .all,
					cells: [
						.headline(
							text: AppStrings.DeltaOnboarding.termsButtonTitle,
							style: .label,
							action: .push(htmlModel: AppInformationModel.termsModel, withTitle: AppStrings.AppInformation.termsNavigation),
							configure: { _, cell, _ in
								cell.accessoryType = .disclosureIndicator
								cell.selectionStyle = .default
							}
						)
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.body(text: AppStrings.DeltaOnboarding.termsDescription2)
					]
				)
			)
		}
	}

	// MARK: - Private

	private let supportedCountries: [Country]

	private func buildCountryCells() -> [DynamicCell] {
		var cells: [DynamicCell] = []
		if supportedCountries.isEmpty {
			cells = [
				.headline(
					text: AppStrings.DeltaOnboarding.participatingCountriesListUnavailableTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.participatingCountriesListUnavailableTitle
				),
				.body(
					text: AppStrings.DeltaOnboarding.participatingCountriesListUnavailable,
						 accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.participatingCountriesListUnavailable
					 )
			]
		} else {
			cells.append(.headline(
				text: AppStrings.ExposureSubmissionWarnOthers.supportedCountriesTitle,
						 accessibilityIdentifier: nil
					 ))
		}
		return cells
	}
}
