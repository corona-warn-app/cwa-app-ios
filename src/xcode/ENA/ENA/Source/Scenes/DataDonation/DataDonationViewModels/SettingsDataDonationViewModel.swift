////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class SettingsDataDonationViewModel: BaseDataDonationViewModel {

	/// we use a slitly different string if no federal state was selected
	override var friendlyFederalStateName: String {
		return dataDonationModel.federalStateName ?? AppStrings.DataDonation.Info.subHeadState
	}

	/// we use a slitly different string if no age was given
	override var friendlyAgeName: String {
		return dataDonationModel.age ?? AppStrings.DataDonation.Info.subHeadAgeGroup
	}

	override var dynamicTableViewModel: DynamicTableViewModel {
		/// create the top section with the illustration and title text
		var dynamicTableViewModel = DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_DataDonation"),
						accessibilityLabel: "AppStrings.DataDonation.Info.accImageDescription",
						accessibilityIdentifier: "AccessibilityIdentifiers.DataDonation.accImageDescription",
						height: 250
					),
					cells: [
						.title1(text: AppStrings.DataDonation.Info.title, accessibilityIdentifier: "AppStrings.DataDonation.Info.title"),
						.headline(text: AppStrings.DataDonation.Info.description)
					]
				)
			)
		}

		/// section to show input fields with already given data
		/// this will change numer of cells by the already entered data
		let sectionCells: [DynamicCell] = [
			.footnote(text: AppStrings.DataDonation.Info.settingsSubHeadline, accessibilityIdentifier: nil),
			.body(
				text: AppStrings.Settings.Datadonation.label,
				style: .label,
				color: nil,
				accessibilityIdentifier: nil,
				accessibilityTraits: .staticText,
				action: .none,
				configure: { [weak self] _, cell, _ in
					guard let self = self else {
						return
					}
					let toggleSwitch = UISwitch()
					cell.accessoryView = toggleSwitch
					toggleSwitch.isOn = self.dataDonationModel.isConsentGiven
					toggleSwitch.onTintColor = .enaColor(for: .tint)
					toggleSwitch.addTarget(self, action: #selector(self.didToggleDatadonationSwitch), for: .valueChanged)
				}),

			dataDonationModel.isConsentGiven == true ?
				.body(
					text: friendlyFederalStateName,
					style: .label,
					accessibilityTraits: .button,
					action: .execute(block: { [weak self] _, _ in
						self?.didTapSelectStateButton()
					}),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
					}):
				nil,

			dataDonationModel.isConsentGiven == true ?
				.body(
					text: friendlyRegionName,
					style: .label, accessibilityIdentifier: nil,
					accessibilityTraits: .button,
					action: .execute(block: { [weak self] _, _ in
						self?.didTapSelectRegionButton()
					}),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
					}) :
				nil,

			dataDonationModel.isConsentGiven == true ?
				.body(
					text: friendlyAgeName,
					style: .label,
					color: nil,
					accessibilityIdentifier: nil,
					accessibilityTraits: .button,
					action: .execute(block: { [weak self] _, _ in
						self?.didTapAgeButton()
					}),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
					}) :
				nil
		]
		.compactMap { $0 }

		dynamicTableViewModel.add(
			.section(
				cells: sectionCells
			)
		)

		/// section for the legal text
		dynamicTableViewModel.add(
			.section(
				cells: [
					.legalExtendedDataDonation(
						title: NSAttributedString(string: AppStrings.),
						description: NSAttributedString(
							string: AppStrings.DataDonation.AppSettings.ppaSettingsPrivacyInformationBody,
							attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]),
						bulletPoints: [
							NSAttributedString(string: AppStrings.DataDonation.Info.legalAcknowledgementBulletPoint1),
							NSAttributedString(string: AppStrings.DataDonation.Info.legalAcknowledgementBulletPoint2),
							NSAttributedString(string: AppStrings.DataDonation.Info.legalAcknowledgementBulletPoint3)],
						accessibilityIdentifier: AppStrings.DataDonation.Info.legalTitle
					)
				]
			)
		)
					
		dynamicTableViewModel.add(
			.section(separators: .all, cells: [
				.body(
					text: AppStrings.DataDonation.Info.dataProcessingDetails,
					style: DynamicCell.TextCellStyle.label,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.dataProcessingDetailInfo,
					accessibilityTraits: UIAccessibilityTraits.link,
					action: .pushDataDonationDetails(model: DataDonationDetailsViewModel().dynamicTableViewModel,
								  withTitle: AppStrings.DataDonation.DetailedInfo.title,
								  completion: nil
					),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
						cell.selectionStyle = .default
					}),
				.space(height: 12)
			])
		)

		return dynamicTableViewModel
	}

	@objc /// called if the consent given switch changes
	private func didToggleDatadonationSwitch(sender: UISwitch) {
		save(consentGiven: sender.isOn)
		DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.35) { [weak self] in
			self?.reloadTableView.toggle()
		}
	}

	private func didTapSelectStateButton() {
		let selectValueViewModel = SelectValueViewModel(
			dataDonationModel.allFederalStateNames,
			title: AppStrings.DataDonation.ValueSelection.Title.State,
			preselected: dataDonationModel.federalStateName
		)
		selectValueViewModel.$selectedValue.sink { [weak self] federalState in
			guard self?.dataDonationModel.federalStateName != federalState else {
				return
			}
			// if a new fedaral state got selected reset region as well
			self?.dataDonationModel.federalStateName = federalState
			self?.dataDonationModel.region = nil
			self?.dataDonationModel.save()
			self?.reloadTableView.toggle()
		}.store(in: &subscriptions)
		presentSelectValueList(selectValueViewModel)
	}

	private func didTapSelectRegionButton() {
		guard let federalStateName = dataDonationModel.federalStateName else {
			Log.debug("Missing federal state to load regions", log: .ppac)
			return
		}

		let selectValueViewModel = SelectValueViewModel(
			dataDonationModel.allRegions(by: federalStateName),
			title: AppStrings.DataDonation.ValueSelection.Title.Region,
			preselected: dataDonationModel.region
		)
		selectValueViewModel.$selectedValue .sink { [weak self] region in
			guard self?.dataDonationModel.region != region else {
				return
			}
			self?.dataDonationModel.region = region
			self?.dataDonationModel.save()
			self?.reloadTableView.toggle()
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}

	private func didTapAgeButton() {
		let selectValueViewModel = SelectValueViewModel(
			AgeGroup.allCases.map({ $0.text }),
			title: AppStrings.DataDonation.ValueSelection.Title.Age,
			preselected: dataDonationModel.age
		)
		selectValueViewModel.$selectedValue .sink { [weak self] age in
			guard self?.dataDonationModel.age != age else {
				return
			}
			self?.dataDonationModel.age = age
			self?.dataDonationModel.save()
			self?.reloadTableView.toggle()
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}

}
