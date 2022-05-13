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
		self.localDate = SystemTime.localDateFormatter.string(from: date)
		self.localDateTime = SystemTime.localDateTimeFormatter.string(from: date)
		self.localDateTimeMidnight = SystemTime.localDateMidnightTimeFormatter.string(from: date)
		self.utcDate = SystemTime.utcDateFormatter.string(from: date)
		self.utcDateTime = SystemTime.utcDateTimeFormatter.string(from: date)
		self.utcDateTimeMidnight = SystemTime.utcDateTimeMidnightFormatter.string(from: date)
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
		boosterNotificationRules: [Rule],
		invalidationRules: [Rule],
		identifier: String?
	) -> [String: AnyDecodable] {
		return CCLDefaultInput.addingTo(
			parameters: [
				"certificates": AnyDecodable(certificates),
				"boosterNotificationRules": AnyDecodable(boosterNotificationRules),
				"invalidationRules": AnyDecodable(invalidationRules),
				"scenarioIdentifier": AnyDecodable(identifier)
			],
			date: date,
			language: language
		)
	}
}

enum GetAdmissionCheckScenariosInput {
	
	static func make(
		with date: Date = Date(),
		language: String = Locale.current.languageCode ?? "en"
	) -> [String: AnyDecodable] {
		return CCLDefaultInput.addingTo(
			parameters: [:],
			date: date,
			language: language
		)
	}

}

extension SystemTime {
	
	// MARK: - DateFormatters

	static let localDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.autoupdatingCurrent
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T10:00:00+01:00
	static let localDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.autoupdatingCurrent
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T00:00:00+01:00
	static let localDateMidnightTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.autoupdatingCurrent
		formatter.dateFormat = "yyyy-MM-dd'T00:00:00'xxx"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	static let utcDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T09:00:00Z
	static let utcDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
	
	// 2021-12-30T00:00:00Z
	static let utcDateTimeMidnightFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T00:00:00Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
}
