//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

/*** this protocol gets used to provide different view model classes for the dataDonationViewController */

protocol DataDonationViewModelProtocol {

	// dataDonationModel and it's Publisher to subscribe changes
	var dataDonationModel: DataDonationModel { get }
	var dataDonationModelPublisher: OpenCombine.Published<DataDonationModel>.Publisher { get }

	var friendlyFederalStateName: String { get }
	var friendlyRegionName: String { get }
	var friendlyAgeName: String { get }
	var dynamicTableViewModel: DynamicTableViewModel { get }

	func save(consentGiven: Bool)
}

class BaseDataDonationViewModel: DataDonationViewModelProtocol {

	// MARK: - Init

	init(
		store: Store,
		presentSelectValueList: @escaping (SelectValueViewModel) -> Void,
		datadonationModel: DataDonationModel
	) {
		self.presentSelectValueList = presentSelectValueList
		self.dataDonationModel = datadonationModel
	}

	// MARK: - Protocol DataDonationViewModelProtocol

	let presentSelectValueList: (SelectValueViewModel) -> Void

	@OpenCombine.Published var dataDonationModel: DataDonationModel
	var dataDonationModelPublisher: OpenCombine.Published<DataDonationModel>.Publisher { $dataDonationModel }

	var subscriptions: [AnyCancellable] = []

	var dynamicTableViewModel: DynamicTableViewModel {
		fatalError("base implementation should never get called")
	}

	/// formatted name output
	var friendlyFederalStateName: String {
		return dataDonationModel.federalStateName ?? AppStrings.DataDonation.Info.noSelectionState
	}

	/// formatted region output
	var friendlyRegionName: String {
		return dataDonationModel.region ?? AppStrings.DataDonation.Info.noSelectionRegion
	}

	/// formatted age output
	var friendlyAgeName: String {
		return dataDonationModel.age ?? AppStrings.DataDonation.Info.noSelectionAgeGroup
	}

	/// will set consent given and save the model afterwards
	func save(consentGiven: Bool) {
		dataDonationModel.isConsentGiven = consentGiven
		Log.debug("DataDonation consent value set to '\(consentGiven)'")
		dataDonationModel.save()
	}
}

internal extension DynamicCell {

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

	static func dataProcessingDetails() -> Self {
		.body(
			text: AppStrings.DataDonation.Info.dataProcessingDetails,
			style: DynamicCell.TextCellStyle.label,
			accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.dataProcessingDetailInfo,
			accessibilityTraits: UIAccessibilityTraits.link,
			action: .pushDataDonationDetails(model: DataDonationDetailsViewModel().dynamicTableViewModel,
											 withTitle: AppStrings.DataDonation.DetailedInfo.title,
											 completion: nil),
			configure: { _, cell, _ in
				cell.accessoryView = nil
				cell.accessoryType = .disclosureIndicator
				cell.selectionStyle = .default
			})
	}
}
