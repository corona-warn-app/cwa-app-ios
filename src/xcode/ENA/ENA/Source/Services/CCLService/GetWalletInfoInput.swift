//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable
import CertLogic

struct SystemTime: Codable {
	
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
		let systemTime = SystemTime(
			timestamp: Int(Date().timeIntervalSince1970),
			localDate: DateFormatter.localDateFormatter.string(from: date),
			localDateTime: DateFormatter.localDateTimeFormatter.string(from: date),
			localDateTimeMidnight: DateFormatter.localDateMidnightTimeFormatter.string(from: date),
			utcDate: DateFormatter.utcDateFormatter.string(from: date),
			utcDateTime: DateFormatter.utcDateTimeFormatter.string(from: date),
			utcDateTimeMidnight: DateFormatter.utcDateTimeMidnightFormatter.string(from: date)
		)
		return [
			"os": AnyDecodable("ios"),
			"language": AnyDecodable(language),
			"now": AnyDecodable(systemTime),
			"certificates": AnyDecodable(certificates),
			"boosterNotificationRules": AnyDecodable(boosterNotificationRules)
		]
	}
}
