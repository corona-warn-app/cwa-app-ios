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

final class CachedAppConfiguration {
	// MARK: Creating a Cached App Configuration
	init(client: Client) {
		self.client = client
	}

	// MARK: Properties
	private let client: Client
	private var cache: Cache?
}

extension CachedAppConfiguration: AppConfigurationProviding {
	func appConfiguration(completion: @escaping Completion) {
		guard let cache = cache else {
			actuallyDownloadAppConfiguration(completion: completion)
			return
		}

		let calendar = Calendar.current
		let deltaInMinutes = abs(calendar.dateComponents([.minute], from: cache.date, to: Date()).minute ?? .max)
		if deltaInMinutes < 5 {
			completion(cache.value)
			return
		}
		actuallyDownloadAppConfiguration(completion: completion)
	}

	private func actuallyDownloadAppConfiguration(completion: @escaping Completion) {
		client.appConfiguration { [weak self] appConfiguration in
			guard let appConfiguration = appConfiguration else {
				self?.cache = nil
				completion(nil)
				return
			}
			self?.cache = .init(date: Date(), value: appConfiguration)
			completion(appConfiguration)
		}
	}
}

private extension CachedAppConfiguration {
	struct Cache {
		let date: Date
		let value: SAP_ApplicationConfiguration
	}
}
