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
import Combine
import ZIPFoundation

#if DEBUG
final class CachedAppConfigurationMock: AppConfigurationProviding {

	private let config: SAP_Internal_ApplicationConfiguration

	init(config: SAP_Internal_ApplicationConfiguration? = nil) {
		guard
			let url = Bundle.main.url(forResource: "default_app_config_17", withExtension: ""),
			let data = try? Data(contentsOf: url),
			let zip = Archive(data: data, accessMode: .read),
			let staticConfig = try? zip.extractAppConfiguration() else {
			fatalError("Could not fetch static app config")
		}
		self.config = config ?? staticConfig
	}

	func appConfiguration(forceFetch: Bool) -> AnyPublisher<SAP_Internal_ApplicationConfiguration, Never> {
		return Just(config)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func appConfiguration() -> AnyPublisher<SAP_Internal_ApplicationConfiguration, Never> {
		return appConfiguration(forceFetch: false)
	}
}
#endif
