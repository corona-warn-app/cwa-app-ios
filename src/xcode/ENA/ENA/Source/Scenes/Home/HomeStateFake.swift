//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension HomeState {
	
	static func fake() -> HomeState {
		HomeState(
			store: MockTestStore(),
			riskProvider: MockRiskProvider(),
			exposureManagerState: MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: nil).exposureManagerState,
			enState: .enabled,
			statisticsProvider: StatisticsProvidingFake(),
			localStatisticsProvider: LocalStatisticsProvidingFake()
		)
	}
}
