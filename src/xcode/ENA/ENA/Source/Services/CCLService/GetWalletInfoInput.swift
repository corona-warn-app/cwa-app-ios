//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable
import CertLogic

struct SystemTime: Codable {
	
	// MARK: - Init

	init(_ date: Date) {
		self.timestamp = Int(date.timeIntervalSince1970)
		self.localDate = DateFormatter.localDateFormatter.string(from: date)
		self.localDateTime = DateFormatter.localDateTimeFormatter.string(from: date)
		self.localDateTimeMidnight = DateFormatter.localDateMidnightTimeFormatter.string(from: date)
		self.utcDate = DateFormatter.utcDateFormatter.string(from: date)
		self.utcDateTime = DateFormatter.utcDateTimeFormatter.string(from: date)
		self.utcDateTimeMidnight = DateFormatter.utcDateTimeMidnightFormatter.string(from: date)
	}
	
	// MARK: - Internal

	let timestamp: Int
	let localDate: String
	let localDateTime: String
	let localDateTimeMidnight: String
	let utcDate: String
	let utcDateTime: String
	let utcDateTimeMidnight: String
}

enum CCLDefaultInput {
	
	static func addingTo(
		parameters: [String: AnyDecodable],
		date: Date = Date(),
		language: String = Locale.current.languageCode ?? "en"
	) -> [String: AnyDecodable] {
		var parametersWithDefaults = parameters
		parametersWithDefaults["os"] = AnyDecodable("ios")
		parametersWithDefaults["language"] = AnyDecodable(language)
		parametersWithDefaults["now"] = AnyDecodable(SystemTime(date))
		return parametersWithDefaults
	}
}

enum GetWalletInfoInput {
	
	static func make(
		with date: Date = Date(),
		language: String = Locale.current.languageCode ?? "en",
		certificates: [DCCWalletCertificate],
		boosterNotificationRules: [Rule]
	) -> [String: AnyDecodable] {
		return CCLDefaultInput.addingTo(
			parameters: [
				"certificates": AnyDecodable(certificates),
				"boosterNotificationRules": AnyDecodable(boosterNotificationRules)
			],
			date: date,
			language: language
		)
	}
}
