//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
@testable import ENA

final class CachingHTTPClientMock: CachingHTTPClient {

	convenience init(store: Store? = nil) {
		if let store = store {
			let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: store)
			self.init(clientConfiguration: configuration)
		} else {
			let serverEnvironment = ServerEnvironment()
			let store = SecureStore(subDirectory: "database", serverEnvironment: serverEnvironment)
			let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: store)
			self.init(clientConfiguration: configuration)
		}
	}

	static let staticAppConfig: SAP_ApplicationConfiguration = {
		let bundle = Bundle(for: CachingHTTPClientMock.self)
		// there is a test for this (`testStaticAppConfiguration`), let's keep it short.
		guard
			let fixtureUrl = bundle.url(forResource: "de-config-int-2020-09-25", withExtension: nil),
			let fixtureData = try? Data(contentsOf: fixtureUrl),
			let bucket = SAPDownloadedPackage(compressedData: fixtureData),
			let config = try? SAP_ApplicationConfiguration(serializedData: bucket.bin)
		else {
			assertionFailure("check this!")
			return SAP_ApplicationConfiguration()
		}
		return config
	}()

	// MARK: AppConfigurationFetching

	var onFetchAppConfiguration: ((String?, @escaping CachingHTTPClient.AppConfigResultHandler) -> Void)?

	override func fetchAppConfiguration(etag: String? = nil, completion: @escaping CachingHTTPClient.AppConfigResultHandler) {
		guard let handler = self.onFetchAppConfiguration else {
			let response = AppConfigurationFetchingResponse(CachingHTTPClientMock.staticAppConfig, "fake")
			completion(.success(response))
			return
		}
		handler(etag, completion)
	}
}
