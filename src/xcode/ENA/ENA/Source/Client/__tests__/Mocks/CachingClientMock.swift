//
// 🦠 Corona-Warn-App
//

import Foundation

final class CachingHTTPClientMock: CachingHTTPClient {

	static let staticAppConfig: SAP_ApplicationConfiguration = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		// there is a test for this (`testStaticAppConfiguration`), let's keep it short.
		guard
			let fixtureUrl = bundle.url(forResource: "de-config-int-2020-09-25", withExtension: nil),
			let fixtureData = try? Data(contentsOf: fixtureUrl),
			let bucket = SAPDownloadedPackage(compressedData: fixtureData),
			let config = try? SAP_ApplicationConfiguration(serializedData: bucket.bin)
		else { return SAP_ApplicationConfiguration() }
		return config
	}()

	// MARK: AppConfigurationFetching

	typealias AppFetchHandler = (Result<SAP_ApplicationConfiguration, Error>) -> Void
	var onFetchAppConfiguration: ((Bool, @escaping AppFetchHandler) -> Void)?


//	func appConfiguration(forceFetch: Bool, completion: @escaping Completion) {
//		guard let handler = self.onFetchAppConfiguration else {
//			completion(.success(CachingClientMock.staticAppConfig))
//			return
//		}
//		handler(forceFetch, completion)
//	}
//
//	func appConfiguration(completion: @escaping Completion) {
//		appConfiguration(forceFetch: false, completion: completion)
//	}
}
