//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
@testable import ENA

class LocalStatisticsProvidingFake: LocalStatisticsProviding {
	var regionStatisticsData: CurrentValueSubject<[RegionStatisticsData], Never> = .init([RegionStatisticsData]())
	
	func add(_ region: LocalStatisticsRegion) { }
	func remove(_ region: LocalStatisticsRegion) { }
	func updateLocalStatistics(completion: ((Result<Void, Error>) -> Void)?) { }
	
}
