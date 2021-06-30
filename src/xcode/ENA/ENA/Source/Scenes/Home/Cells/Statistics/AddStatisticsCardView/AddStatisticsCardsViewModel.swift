////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class AddStatisticsCardsViewModel {
	
	// MARK: - Init
	
	init(
		localStatisticsModel: AddLocalStatisticsModel,
		presentFederalStatesList: @escaping (SelectValueViewModel) -> Void,
		presentSelectDistrictsList: @escaping (SelectValueViewModel) -> Void,
		onFetchFederalState: @escaping (LocalStatisticsDistrict) -> Void
	) {
		self.presentFederalStatesList = presentFederalStatesList
		self.presentSelectDistrictsList = presentSelectDistrictsList
		self.onFetchFederalState = onFetchFederalState
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
			accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.federalStateCell,
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
			accessibilityIdentifier: AccessibilityIdentifiers.DataDonation.regionCell,
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
		let districtIDWithPadding = String(describing: districtIDValue)
		let districtIDWithoutPadding = String(describing: districtIDWithPadding.dropFirst(3))

		let localDistrict = LocalStatisticsDistrict(
			federalState: state,
			districtName: district,
			districtId: districtIDWithoutPadding
		)
		self.district = localDistrict
		onFetchFederalState(localDistrict)
	}
	
	private var federalState: String?
	private(set) var district: LocalStatisticsDistrict?
	private var subscriptions: [AnyCancellable] = []

	private let localStatisticsModel: AddLocalStatisticsModel
	private let presentFederalStatesList: (SelectValueViewModel) -> Void
	private let presentSelectDistrictsList: (SelectValueViewModel) -> Void
	private let onFetchFederalState: (LocalStatisticsDistrict) -> Void
}
