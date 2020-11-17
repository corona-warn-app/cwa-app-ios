//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class CachingHTTPClientMock: CachingHTTPClient {

	convenience init(store: Store = MockTestStore()) {
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: store)
		self.init(clientConfiguration: configuration)
	}

	static let staticAppConfig: SAP_Internal_V2_ApplicationConfigurationIOS = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		// there is a test for this (`testStaticAppConfiguration`), let's keep it short.
		guard
			let fixtureUrl = bundle.url(forResource: "config-wru-2020-11-13", withExtension: nil),
			let fixtureData = try? Data(contentsOf: fixtureUrl),
			let bucket = SAPDownloadedPackage(compressedData: fixtureData),
			let config = try? SAP_Internal_V2_ApplicationConfigurationIOS(serializedData: bucket.bin)
		else {
			assertionFailure("check this!")
			return SAP_Internal_V2_ApplicationConfigurationIOS()
		}
		return config
	}()

	static let staticAppConfigMetadata: AppConfigMetadata = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		let configMetadata = AppConfigMetadata(lastAppConfigETag: "\"SomeETag\"", lastAppConfigFetch: .distantPast, appConfig: CachingHTTPClientMock.staticAppConfig)
		return configMetadata
	}()

	// MARK: AppConfigurationFetching

	var onFetchAppConfiguration: ((String?, @escaping CachingHTTPClient.AppConfigResultHandler) -> Void)?

	override func fetchAppConfiguration(etag: String? = nil, completion: @escaping CachingHTTPClient.AppConfigResultHandler) {
		guard let handler = self.onFetchAppConfiguration else {
			let response = AppConfigurationFetchingResponse(CachingHTTPClientMock.staticAppConfig, "fake")
			completion((.success(response), nil))
			return
		}
		handler(etag, completion)
	}
}
