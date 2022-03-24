//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
@testable import ENA

class StatisticsProvidingFake: StatisticsProviding {
	func statistics() -> AnyPublisher<SAP_Internal_Stats_Statistics, Error> {
		let statistics = SAP_Internal_Stats_Statistics()
		return Just(statistics).setFailureType(to: Error.self).eraseToAnyPublisher()
	}
}
