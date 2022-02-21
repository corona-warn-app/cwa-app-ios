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
		onFetchGroupData: @escaping (LocalStatisticsRegion) -> Void
	) {
		self.presentFederalStatesList = presentFederalStatesList
		self.presentSelectDistrictsList = presentSelectDistrictsList
		self.onFetchGroupData = onFetchGroupData
		self.localStatisticsModel = localStatisticsModel
	}

	// MARK: - Internal
	
	func presentStateSelection() {
		let initialValue = SelectableValue(title: AppStrings.Statistics.Card.fromNationWide, isEnabled: false)
		let selectableStates = localStatisticsModel.allFederalStateNames.map {
			SelectableValue(title: $0)
		}
		let selectValueViewModel = SelectValueViewModel(
			selectableStates,
			title: AppStrings.DataDonation.ValueSelection.Title.FederalState,
			preselected: nil,
			initialValue: initialValue,
			accessibilityIdentifier: AccessibilityIdentifiers.LocalStatistics.selectState,
			selectionCellIconType: .discloseIndicator
		)
		selectValueViewModel.$selectedValue.sink { [weak self] federalState in
			guard let state = federalState else {
				return
			}
			self?.federalState = state.title
			self?.showSelectDistrictList(for: state.title)
		}.store(in: &subscriptions)
		presentFederalStatesList(selectValueViewModel)
	}
	
	// MARK: - Private

	private func showSelectDistrictList(for federalStateName: String) {
		let initialValue = SelectableValue(title: AppStrings.Statistics.AddCard.stateWide, isEnabled: true)
		let selectableRegions = localStatisticsModel.allRegions(by: federalStateName).map {
			SelectableValue(title: $0)
		}
		let selectValueViewModel = SelectValueViewModel(
			selectableRegions,
			title: AppStrings.DataDonation.ValueSelection.Title.Region,
			preselected: nil,
			isInitialCellWithValue: true, initialValue: initialValue,
			accessibilityIdentifier: AccessibilityIdentifiers.LocalStatistics.selectDistrict,
			selectionCellIconType: .none
		)
		selectValueViewModel.$selectedValue.sink { [weak self] district in
			guard let unWrappedDistrict = district else {
				Log.warning("AddStatistics District is nil", log: .localStatistics)
				return
			}
			self?.generateFilterID(for: unWrappedDistrict.title)
		}.store(in: &subscriptions)

		presentSelectDistrictsList(selectValueViewModel)
	}

	private func generateFilterID(for district: String) {
		switch district {
		// If the user taps on the first Cell fetch data for the entire federalState
		case AppStrings.Statistics.AddCard.stateWide:
			guard let federalStateString = self.federalState,
				  let state = LocalStatisticsFederalState.byLocalizedName(federalStateString: federalStateString)
			else {
				Log.warning("federalStateString or state is nil", log: .localStatistics)
				return
			}

			let localDistrict = LocalStatisticsRegion(
				federalState: state,
				name: state.rawValue,
				id: String(state.federalStateProtobufId),
				regionType: .federalState
			)
			self.district = localDistrict
			onFetchGroupData(localDistrict)

		// If not, then fetch data for the specific district
		default:
			let districtInfo = localStatisticsModel.regionId(by: district)
			guard let districtIDValue = districtInfo?.districtID,
				  let federalStateString = self.federalState,
				  let state = LocalStatisticsFederalState.byLocalizedName(federalStateString: federalStateString)
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
			let localDistrict = LocalStatisticsRegion(
				federalState: state,
				name: district,
				id: districtIDWithoutLeadingZeros,
				regionType: .administrativeUnit
			)
			self.district = localDistrict
			onFetchGroupData(localDistrict)
		}
	}
	
	private var federalState: String?
	private(set) var district: LocalStatisticsRegion?
	private var subscriptions: [AnyCancellable] = []

	private let localStatisticsModel: LocalStatisticsModel
	private let presentFederalStatesList: (SelectValueViewModel) -> Void
	private let presentSelectDistrictsList: (SelectValueViewModel) -> Void
	private let onFetchGroupData: (LocalStatisticsRegion) -> Void
}
