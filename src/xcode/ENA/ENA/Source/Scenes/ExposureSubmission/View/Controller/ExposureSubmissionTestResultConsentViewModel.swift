//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class ExposureSubmissionTestResultConsentViewModel {

	// MARK: - Init
	
	init(
		supportedCountries: [Country],
		coronaTestType: CoronaTestType,
		coronaTestService: CoronaTestServiceProviding,
		testResultAvailability: TestResultAvailability,
		dismissCompletion: (() -> Void)?
	) {
		self.supportedCountries = supportedCountries.sortedByLocalizedName
		self.coronaTestType = coronaTestType
		self.coronaTestService = coronaTestService
		self.testResultAvailability = testResultAvailability
		self.dismissCompletion = dismissCompletion
	}

	// MARK: - Public
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					separators: .none,
					cells: [
						.title2(
							text: AppStrings.AutomaticSharingConsent.switchTitle,
							color: nil,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionTestResultConsent.switchIdentifier,
							accessibilityTraits: .header,
							configure: { [weak self] _, cell, _ in
								guard let self = self else {
									return
								}

								let toggleSwitch = UISwitch()
								cell.accessoryView = toggleSwitch
								toggleSwitch.onTintColor = .enaColor(for: .tint)
								toggleSwitch.addTarget(self, action: #selector(self.consentStateChanged), for: .valueChanged)

								switch self.coronaTestType {
								case .pcr:
									self.coronaTestService.pcrTest
										.sink { pcrTest in
											guard let pcrTest = pcrTest else {
												return
											}

											toggleSwitch.isOn = pcrTest.isSubmissionConsentGiven
										}
										.store(in: &self.subscriptions)
								case .antigen:
									self.coronaTestService.antigenTest
										.sink { antigenTest in
											guard let antigenTest = antigenTest else {
												return
											}

											toggleSwitch.isOn = antigenTest.isSubmissionConsentGiven
										}
										.store(in: &self.subscriptions)
								}
							}
						),
						.body(text: AppStrings.AutomaticSharingConsent.switchTitleDescription),
						.custom(
							withIdentifier: ExposureSubmissionTestResultConsentViewController.CustomCellReuseIdentifiers.consentCell,
							action: .none,
							accessoryAction: .none
						) { [weak self] _, cell, _ in
							guard let self = self else {
								return
							}
							if let consentCell = cell as? DynamicTableViewConsentCell {
								// We use this model in two places but require one super important sentence just once. This HACK figures out which 'mode' we use.
								// For reference
								// text needed here: https://www.figma.com/file/BpLyzxHZVa6a8BbSdcL76V/CWA_Submission_Flow_v02?node-id=388%3A3251
								// but not here: https://www.figma.com/file/BpLyzxHZVa6a8BbSdcL76V/CWA_Submission_Flow_v02?node-id=388%3A3183
								var part4: String = AppStrings.AutomaticSharingConsent.consentDescriptionPart4
								if self.testResultAvailability == .availableAndPositive {
									part4.append(" \(AppStrings.AutomaticSharingConsent.consentDescriptionPart5)")
								}

								consentCell.configure(
									subTitleLabel: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentSubTitle),
									descriptionPart1Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart1),
									descriptionPart2Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart2),
									countries: self.supportedCountries,
									descriptionPart3Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart3),
									descriptionPart4Label: NSMutableAttributedString(string: part4)
								)
							}
						},
						.space(height: 20)
					]
				)
			)
			$0.add(
				.section(
					separators: .all,
					cells: [
						.icon(
							nil,
							text: .string(AppStrings.AutomaticSharingConsent.dataProcessingDetailInfo),
							action: .push(
								htmlModel: AppInformationModel.privacyModel,
								withTitle: AppStrings.AppInformation.privacyTitle,
								completion: dismissCompletion
							),
							configure: { _, cell, _ in
								cell.accessoryType = .disclosureIndicator
								cell.selectionStyle = .default
								cell.backgroundColor = .enaColor(for: .background)
							}
						)
					]
				)

			)
			$0.add(
				.section(
					cells: [
						.space(height: 50)
					]

				)
			)
		}
	}

	// MARK: - Private

	private let supportedCountries: [Country]
	private let coronaTestType: CoronaTestType
	private var coronaTestService: CoronaTestServiceProviding
	private let testResultAvailability: TestResultAvailability
	private let dismissCompletion: (() -> Void)?
	
	private var subscriptions = Set<AnyCancellable>()

	@objc
	private func consentStateChanged(switchState: UISwitch) {
		Analytics.collect(.keySubmissionMetadata(.advancedConsentGiven(switchState.isOn, coronaTestType)))

		switch coronaTestType {
		case .pcr:
			coronaTestService.pcrTest.value?.isSubmissionConsentGiven = switchState.isOn
		case .antigen:
			coronaTestService.antigenTest.value?.isSubmissionConsentGiven = switchState.isOn
		}
	}

}

// MARK: - TestResultAvailability

enum TestResultAvailability {
	case availableAndPositive
	case notAvailable
}
