////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class ManageStatisticsCardsViewModel {
	
	// MARK: - Init
	
	init(
		localStatisticsModel: LocalStatisticsModel,
		presentFederalStatesList: @escaping (SelectValueViewModel) -> Void,
		presentSelectDistrictsList: @escaping (SelectValueViewModel) -> Void,
		onFetchGroupData: @escaping (LocalStatisticsDistrict) -> Void
	) {
		self.presentFederalStatesList = presentFederalStatesList
		self.presentSelectDistrictsList = presentSelectDistrictsList
		self.onFetchGroupData = onFetchGroupData
		self.localStatisticsModel = localStatisticsModel
	}

	// MARK: - Internal
	
	func presentStateSelection() {
		let selectValueViewModel = SelectValueViewModel(
			localStatisticsModel.allFederalStateNames,
			title: AppStrings.DataDonation.ValueSelection.Title.FederalState,
			preselected: nil,
			isInitialCellEnabled: false,
			initialString: AppStrings.Statistics.Card.fromNationWide,
			accessibilityIdentifier: AccessibilityIdentifiers.LocalStatistics.selectState,
			selectionCellIconType: .discloseIndicator
		)
		selectValueViewModel.$selectedValue.sink { [weak self] federalState in
			guard let state = federalState else {
				return
			}
			self?.federalState = state
			self?.showSelectDistrictList(for: state)
		}.store(in: &subscriptions)
		presentFederalStatesList(selectValueViewModel)
	}
	
	// MARK: - Private

	private func showSelectDistrictList(for federalStateName: String) {

		let selectValueViewModel = SelectValueViewModel(
			localStatisticsModel.allRegions(by: federalStateName),
			title: AppStrings.DataDonation.ValueSelection.Title.Region,
			preselected: nil,
			isInitialCellEnabled: false,
			initialString: AppStrings.Statistics.AddCard.stateWide,
			accessibilityIdentifier: AccessibilityIdentifiers.LocalStatistics.selectDistrict,
			selectionCellIconType: .none
		)
		selectValueViewModel.$selectedValue.sink { [weak self] district in
			guard let unWrappedDistrict = district else {
				Log.warning("AddStatistics District is nil", log: .localStatistics)
				return
			}
			self?.generateFilterID(for: unWrappedDistrict)
		}.store(in: &subscriptions)

		presentSelectDistrictsList(selectValueViewModel)
	}

	private func generateFilterID(for district: String) {
		let districtInfo = localStatisticsModel.regionId(by: district)
		guard let districtIDValue = districtInfo?.districtID,
			  let federalStateString = self.federalState,
			  let state = LocalStatisticsFederalState(rawValue: federalStateString)
		else {
			Log.warning("districtIDValue, federalStateString or state is nil", log: .localStatistics)
			return
		}
		// eg id = 1100452
		// Convert the id value to string so we can remove the first 3 characters
		let districtIDWithoutPadding = String(describing: districtIDValue).dropFirst(3)
		// eg districtIDWithoutPadding = "0452"
		let districtIDWithoutLeadingZeros = String(Int(districtIDWithoutPadding) ?? 0)
		// eg districtIDWithoutPaddingValue = "452"

		let localDistrict = LocalStatisticsDistrict(
			federalState: state,
			districtName: district,
			districtId: districtIDWithoutLeadingZeros
		)
		self.district = localDistrict
		onFetchGroupData(localDistrict)
	}
	
	private var federalState: String?
	private(set) var district: LocalStatisticsDistrict?
	private var subscriptions: [AnyCancellable] = []

	private let localStatisticsModel: LocalStatisticsModel
	private let presentFederalStatesList: (SelectValueViewModel) -> Void
	private let presentSelectDistrictsList: (SelectValueViewModel) -> Void
	private let onFetchGroupData: (LocalStatisticsDistrict) -> Void
}
