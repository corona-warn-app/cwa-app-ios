//
// 🦠 Corona-Warn-App
//

import Foundation

struct AppConfigMetadata: Codable, Equatable {
	
	// MARK: - Init
	
	init(
		lastAppConfigETag: String,
		lastAppConfigFetch: Date,
		appConfig: SAP_Internal_V2_ApplicationConfigurationIOS
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
		appConfig = try SAP_Internal_V2_ApplicationConfigurationIOS(serializedData: appConfigData)
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
	var appConfig: SAP_Internal_V2_ApplicationConfigurationIOS
	
	mutating func refeshLastAppConfigFetchDate() {
		lastAppConfigFetch = Date()
	}
}
