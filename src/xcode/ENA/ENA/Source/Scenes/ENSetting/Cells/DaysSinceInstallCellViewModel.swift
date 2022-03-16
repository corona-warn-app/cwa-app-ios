//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class DaysSinceInstallCellViewModel {
	
	// MARK: - Init

	init(
		store: Store,
		appConfigProvider: AppConfigurationProviding
	) {
		self.store = store
		self.appConfigProvider = appConfigProvider
	}

	// MARK: - Internal

	var daysSinceInstall: Int {
		store.appInstallationDate.map { Calendar.autoupdatingCurrent.startOfDay(for: $0).ageInDays ?? 0 } ?? 0
	}
	
	func maxEncounterAgeInDays(completion: @escaping (Int) -> Void) {
		appConfigProvider.appConfiguration().sink { appConfig in
			completion(Int(appConfig.riskCalculationParameters.defaultedMaxEncounterAgeInDays))
		}.store(in: &subscriptions)
	}
	
	// MARK: - Private
	
	private let store: Store
	private let appConfigProvider: AppConfigurationProviding
	private var subscriptions: Set<AnyCancellable> = []
	
}
