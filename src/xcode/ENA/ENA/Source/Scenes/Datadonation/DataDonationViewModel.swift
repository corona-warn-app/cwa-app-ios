////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class DataDonationViewModel {

	// MARK: - Init

	init(
		store: Store,
		presentSelectValueList: @escaping (SelectValueViewModel) -> Void,
		datadonationModel: DataDonationModel
	) {
		self.presentSelectValueList = presentSelectValueList
		self.reloadTableView = false
		self.dataDonationModel = datadonationModel
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	func save(consentGiven: Bool) {
		dataDonationModel.isConsentGiven = consentGiven
		Log.debug("DataDonation consent value set to '\(consentGiven)'")
		dataDonationModel.save()
	}

	// MARK: - Internal

	@OpenCombine.Published private (set) var reloadTableView: Bool

	var dynamicTableViewModel: DynamicTableViewModel {
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
			.headline(text: AppStrings.DataDonation.Info.subHeadState),

			.body(text: friendlyFederalStateName, style: .label, accessibilityTraits: .button, action: .execute(block: { [weak self] _, _ in
				self?.didTapSelectStateButton()
			}), configure: { _, cell, _ in
				cell.accessoryType = .disclosureIndicator
			}),
			dataDonationModel.federalStateName != nil ?
				.body(text: friendlyRegionName, style: .label, accessibilityIdentifier: nil, accessibilityTraits: .button, action: .execute(block: { [weak self] _, _ in
					self?.didTapSelectRegionButton()
				}), configure: { _, cell, _ in
					cell.accessoryType = .disclosureIndicator
				}) :
				nil,
			.headline(text: AppStrings.DataDonation.Info.subHeadAgeGroup),
			.body(text: friendlyAgeName, style: .label, color: nil, accessibilityIdentifier: nil, accessibilityTraits: .button, action: .execute(block: { [weak self] _, _ in
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

	// MARK: - Private

	private let presentSelectValueList: (SelectValueViewModel) -> Void

	private var dataDonationModel: DataDonationModel
	private var subscriptions: [AnyCancellable] = []

	private var friendlyFederalStateName: String {
		return dataDonationModel.federalStateName ?? AppStrings.DataDonation.Info.noSelectionState
	}

	private var friendlyRegionName: String {
		return dataDonationModel.region ?? AppStrings.DataDonation.Info.noSelectionRegion
	}

	private var friendlyAgeName: String {
		return dataDonationModel.age ?? AppStrings.DataDonation.Info.noSelectionAgeGroup
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
			self?.reloadTableView.toggle()
		}.store(in: &subscriptions)

		presentSelectValueList(selectValueViewModel)
	}

}

extension DynamicCell {

	/// A `legalExtendedDataDonation` to display legal text for Data Donation screen
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - description: Optional description text.
	///   - bulletPoints: A list of strings to be prefixed with bullet points.
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	///   - configure: Optional custom cell configuration
	/// - Returns: A `DynamicCell` to display legal texts
	static func legalExtendedDataDonation(
		title: NSAttributedString,
		description: NSAttributedString?,
		bulletPoints: [NSAttributedString]? =  nil,
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(DataDonationViewController.CustomCellReuseIdentifiers.legalExtended) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicLegalExtendedCell else {
				fatalError("could not initialize cell of type `DynamicLegalExtendedCell`")
			}
			cell.configure(title: title, description: description, bulletPoints: bulletPoints)
			configure?(viewController, cell, indexPath)
		}
	}

}
