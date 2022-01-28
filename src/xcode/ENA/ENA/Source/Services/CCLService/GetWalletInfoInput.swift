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

enum GetWalletInfoInput {
	
	static func make(
		with date: Date = Date(),
		language: String,
		certificates: [DCCWalletCertificate],
		boosterNotificationRules: [Rule]
	) -> [String: AnyDecodable] {
		let systemTime = SystemTime(date)
		return [
			"os": AnyDecodable("ios"),
			"language": AnyDecodable(language),
			"now": AnyDecodable(systemTime),
			"certificates": AnyDecodable(certificates),
			"boosterNotificationRules": AnyDecodable(boosterNotificationRules)
		]
	}
}
