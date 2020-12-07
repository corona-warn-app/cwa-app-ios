//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

class ExposureSubmissionTestResultConsentViewModel {

	// MARK: - Init
	
	init(
		supportedCountries: [Country],
		exposureSubmissionService: ExposureSubmissionService,
		onDismiss: (() -> Void)?
	) {
		self.supportedCountries = supportedCountries.sorted { $0.localizedName.localizedCompare($1.localizedName) == .orderedAscending }
		self.exposureSubmissionService = exposureSubmissionService
		self.onDismiss = onDismiss
	}

	// MARK: - Public

	// MARK: - Internal

	let onDismiss: (() -> Void)?

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					separators: .none,
					cells: [
						.title2(
							text: AppStrings.AutomaticSharingConsent.switchTitle,
							color: nil,
							accessibilityIdentifier: nil,
							accessibilityTraits: .header,
							configure: {[weak self] _, cell, _ in
								guard let self = self else {
									return
								}
								let toggleSwitch = UISwitch()
								cell.accessoryView = toggleSwitch
								toggleSwitch.onTintColor = .enaColor(for: .tint)
								toggleSwitch.addTarget(self, action: #selector(self.consentStateChanged), for: .valueChanged)
								
								self.exposureSubmissionService.isSubmissionConsentGivenPublisher.sink { isSubmissionConsentGiven in
									toggleSwitch.isOn = isSubmissionConsentGiven
								}.store(in: &self.cancellables)
							}
						),
						.body(text: AppStrings.AutomaticSharingConsent.switchTitleDescription),
						.custom(
							withIdentifier: ExposureSubmissionTestResultConsentViewController.CustomCellReuseIdentifiers.consentCell,
							action: .none,
							accessoryAction: .none) {[weak self] _, cell, _ in
								guard let self = self else {
									return
								}
								if let consentCell = cell as? DynamicTableViewConsentCell {
									consentCell.configure(
										subTitleLabel: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentSubTitle),
										descriptionPart1Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart1),
										descriptionPart2Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart2),
										countries: self.supportedCountries,
										descriptionPart3Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart3),
										descriptionPart4Label: NSMutableAttributedString(string: "\(AppStrings.AutomaticSharingConsent.consentDescriptionPart4) \(AppStrings.AutomaticSharingConsent.consentDescriptionPart5)")
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
							action: .push(model: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyTitle),
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
					cells:[
						.space(height: 50)
					]

				)
			)
		}
	}

	// MARK: - Private

	private let supportedCountries: [Country]

	private var cancellables: Set<AnyCancellable> = []
	private var exposureSubmissionService: ExposureSubmissionService

	@objc
	private func consentStateChanged(switchState: UISwitch) {
		exposureSubmissionService.isSubmissionConsentGiven = switchState.isOn
	}

}
