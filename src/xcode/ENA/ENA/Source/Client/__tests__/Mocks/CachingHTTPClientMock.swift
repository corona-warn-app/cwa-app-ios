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

	static let staticAppConfig = SAP_Internal_V2_ApplicationConfigurationIOS()

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
