//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class DefaultDataDonationViewModel: BaseDataDonationViewModel {

	// MARK: - Overrides

	/// override layout of the dynamiv tableview model
	override var dynamicTableViewModel: DynamicTableViewModel {
		/// create the top section with the illustration and title text
		var dynamicTableViewModel = DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.headline(text: AppStrings.DataDonation.Info.introductionText)
					]
				)
			)
		}

		/// section to show input fields with already given data
		/// this will change numer of cells by the already entered data
		let sectionCells: [DynamicCell] = [
			.headline(text: AppStrings.DataDonation.Info.subHeadState),
			.body(text: friendlyFederalStateName,
				  style: .label,
				  accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.federalStateName,
				  accessibilityTraits: .button,
				  action: .execute(block: { [weak self] _, _ in
					self?.didTapSelectStateButton()
				  }), configure: { _, cell, _ in
					cell.accessoryType = .disclosureIndicator
				}),
			dataDonationModel.federalStateName != nil ?
				.body(text: friendlyRegionName,
					  style: .label,
					  accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.regionName,
					  accessibilityTraits: .button,
					  action: .execute(block: { [weak self] _, _ in
						self?.didTapSelectRegionButton()
					  }), configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
					}) :
				nil,
			.headline(text: AppStrings.DataDonation.Info.subHeadAgeGroup),
			.body(text: friendlyAgeName,
				  style: .label,
				  color: nil,
				  accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.ageGroup,
				  accessibilityTraits: .button,
				  action: .execute(block: { [weak self] _, _ in
					self?.didTapAgeButton()
				  }), configure: { _, cell, _ in
					cell.accessoryType = .disclosureIndicator
				})
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
					.headline(text: AppStrings.DataDonation.Info.description),
					.legalExtendedDataDonation(
						title: NSAttributedString(string: AppStrings.DataDonation.Info.legalTitle),
						description: NSAttributedString(
							string: AppStrings.DataDonation.Info.legalAcknowledgementContent,
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
				.dataProcessingDetails(),
				.space(height: 12)
			])
		)

		return dynamicTableViewModel
	}

	// MARK: - Internal

	func didTapSelectStateButton() {
		let selectValueViewModel = SelectValueViewModel(
			dataDonationModel.allFederalStateNames,
			title: AppStrings.DataDonation.ValueSelection.Title.FederalState,
			preselected: dataDonationModel.federalStateName,
			accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.federalStateCell
		)
		selectValueViewModel.$selectedValue.sink { [weak self] federalState in
			guard self?.dataDonationModel.federalStateName != federalState else {
				return
			}
			// if a new fedaral state got selected reset region as well
			self?.dataDonationModel.federalStateName = federalState
			self?.dataDonationModel.region = nil
		}.store(in: &subscriptions)
		presentSelectValueList(selectValueViewModel)
	}

	func didTapSelectRegionButton() {
		guard let federalStateName = dataDonationModel.federalStateName else {
			Log.debug("Missing federal state to load regions", log: .ppac)
			return
		}

		let selectValueViewModel = SelectValueViewModel(
			dataDonationModel.allRegions(by: federalStateName),
			title: AppStrings.DataDonation.ValueSelection.Title.Region,
			preselected: dataDonationModel.region,
			accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.regionCell
		)
		selectValueViewModel.$selectedValue .sink { [weak self] region in
			guard self?.dataDonationModel.region != region else {
				return
			}
			self?.dataDonationModel.region = region
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}

	func didTapAgeButton() {
		let selectValueViewModel = SelectValueViewModel(
			AgeGroup.allCases.map({ $0.text }),
			presorted: true,
			title: AppStrings.DataDonation.ValueSelection.Title.Age,
			preselected: dataDonationModel.age,
			accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.ageGroupCell
		)
		selectValueViewModel.$selectedValue .sink { [weak self] age in
			guard self?.dataDonationModel.age != age else {
				return
			}
			self?.dataDonationModel.age = age
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}

}
