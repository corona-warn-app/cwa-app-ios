//
// 🦠 Corona-Warn-App
//

import Foundation

class StatisticsProvidingFake: StatisticsProviding {
	func statistics() -> AnyPublisher<SAP_Internal_Stats_Statistics, Error> {
	}
}
