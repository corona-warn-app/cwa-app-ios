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

struct AppConfigMetadata: Codable, Equatable {
	
	// MARK: - Init
	
	init(
		lastAppConfigETag: String,
		lastAppConfigFetch: Date,
		appConfig: SAP_Internal_ApplicationConfiguration
	) {
		self.lastAppConfigETag = lastAppConfigETag
		self.lastAppConfigFetch = lastAppConfigFetch
		self.appConfig = appConfig
	}
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case lastAppConfigETag
		case lastAppConfigFetch
		case appConfig
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		lastAppConfigETag = try container.decode(String.self, forKey: .lastAppConfigETag)
		lastAppConfigFetch = try container.decode(Date.self, forKey: .lastAppConfigFetch)
		
		let appConfigData = try container.decode(Data.self, forKey: .appConfig)
		appConfig = try SAP_Internal_ApplicationConfiguration(serializedData: appConfigData)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(lastAppConfigETag, forKey: .lastAppConfigETag)
		try container.encode(lastAppConfigFetch, forKey: .lastAppConfigFetch)
		
		let appConfigData = try appConfig.serializedData()
		try container.encode(appConfigData, forKey: .appConfig)
	}
	
	// MARK: - Internal
	
	var lastAppConfigETag: String
	var lastAppConfigFetch: Date
	var appConfig: SAP_Internal_ApplicationConfiguration
	
	mutating func refeshLastAppConfigFetchDate() {
		lastAppConfigFetch = Date()
	}
}
