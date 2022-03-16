//
// 🦠 Corona-Warn-App
//

import Foundation

class CCLScenariosHelper {
	
	// MARK: - Init
			
	init(cclService: CCLServable, store: HealthCertificateStoring) {
		self.cclService = cclService
		self.store = store
	}
	
	// MARK: - Internal

	func viewModelForAdmissionScenarios() -> Result<SelectValueViewModel, DCCAdmissionCheckScenariosAccessError> {
		let result = self.cclService.dccAdmissionCheckScenarios()
		switch result {
		case .success(let scenarios):
			self.store.dccAdmissionCheckScenarios = scenarios
			let listItems = scenarios.scenarioSelection.items.map({
				SelectableValue(
					title: $0.titleText.localized(cclService: cclService),
					subtitle: $0.subtitleText?.localized(cclService: cclService),
					identifier: $0.identifier,
					isEnabled: $0.enabled
				)
			})
			let selectValueViewModel = SelectValueViewModel(
				listItems,
				presorted: true,
				title: scenarios.scenarioSelection.titleText.localized(cclService: cclService),
				preselected: nil,
				isInitialCellWithValue: true,
				initialValue: nil,
				accessibilityIdentifier: AccessibilityIdentifiers.LocalStatistics.selectState,
				selectionCellIconType: .none
			)
			return .success(selectValueViewModel)
			
		case .failure(let error):
			Log.error(error.localizedDescription)
			return .failure(error)
		}
	}

	// MARK: - Private

	private let cclService: CCLServable
	private let store: HealthCertificateStoring

}
