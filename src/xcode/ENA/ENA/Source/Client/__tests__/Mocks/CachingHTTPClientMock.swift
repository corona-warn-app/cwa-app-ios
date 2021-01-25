//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class CachingHTTPClientMock: CachingHTTPClient {

	convenience init(store: Store = MockTestStore()) {
		self.init(serverEnvironmentProvider: store)
	}

	static let staticAppConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
	static let staticStatistics: SAP_Internal_Stats_Statistics = {
		guard
			let url = Bundle(for: CachingHTTPClientMock.self).url(forResource: "sample_stats", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let stats = try? SAP_Internal_Stats_Statistics(serializedData: data)
		else {
			fatalError("Cannot initialize static test data")
		}
		return stats
	}()

	static let staticAppConfigMetadata: AppConfigMetadata = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		let configMetadata = AppConfigMetadata(lastAppConfigETag: "\"SomeETag\"", lastAppConfigFetch: .distantPast, appConfig: CachingHTTPClientMock.staticAppConfig)
		return configMetadata
	}()

	// MARK: - AppConfigurationFetching

	var onFetchAppConfiguration: ((String?, @escaping CachingHTTPClient.AppConfigResultHandler) -> Void)?

	override func fetchAppConfiguration(etag: String? = nil, completion: @escaping CachingHTTPClient.AppConfigResultHandler) {
		guard let handler = self.onFetchAppConfiguration else {
			let response = AppConfigurationFetchingResponse(CachingHTTPClientMock.staticAppConfig, "fake")
			completion((.success(response), nil))
			return
		}
		handler(etag, completion)
	}

	// MARK: - Statistics

	var onFetchStatistics: ((String?, @escaping CachingHTTPClient.StatisticsFetchingResultHandler) -> Void)?

	override func fetchStatistics(etag: String?, completion: @escaping CachingHTTPClient.StatisticsFetchingResultHandler) {
		guard let handler = self.onFetchStatistics else {
			let response = StatisticsFetchingResponse(CachingHTTPClientMock.staticStatistics, "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}
}
