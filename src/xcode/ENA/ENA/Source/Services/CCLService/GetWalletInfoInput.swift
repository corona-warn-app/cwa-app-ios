//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable
import CertLogic
import AnyCodable

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

private extension DateFormatter {
	
	static var localDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T10:00:00+01:00
	static var localDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T00:00:00+01:00
	static var localDateMidnightTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T00:00:00'ZZZZZ"
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	static var utcDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T09:00:00Z
	static var utcDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T00:00:00Z
	static var utcDateTimeMidnightFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T00:00:00Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
}
