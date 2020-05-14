//
//  DiagnosisKeyAPI.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation


enum DiagnosisKeyAPIError: Error {
	case invalidVersions
	case invalidCountries
	case invalidDates
	case invalidHours
}


final class DiagnosisKeyAPI {
    // MARK: Creating a Diagnosis Key API Instance
    init(
        configuration: BackendConfiguration,
        session: URLSession
    ) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: Properties
    private let session: URLSession
    private let configuration: BackendConfiguration
    private var baseUrl: URL { configuration.baseURL }
	
	// swiftlint:disable:next force_unwrapping
	private(set) lazy var timeZone = TimeZone(identifier: "UTC")!
	
	private(set) lazy var calendar: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = self.timeZone
		return calendar
	}()
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeZone = self.timeZone
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}

	
extension DiagnosisKeyAPI {
	private func url(path components: [String]) -> URL {
		return components.reduce(baseUrl) { url, component in url.appendingPathComponent(component) }
	}
	
	
	private func url(path components: String...) -> URL {
		return url(path: components)
	}
	
	
	private func url(version: String, _ path: String...) -> URL {
		return url(path: ["version", version] + path)
	}
}


extension DiagnosisKeyAPI {
	func fetchApiVersions(completionHandler completion: @escaping (_ error: Error?, _ versions: [String]?) -> Void) {
		session.dataTask(with: url(path: "version")) { data, _, error in
			guard nil == error else {
				completion(error, nil)
				return
			}
			
			if let versions = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String] {
				completion(nil, versions)
			} else {
				completion(DiagnosisKeyAPIError.invalidVersions, nil)
			}
		}
		.resume()
	}
	
	
	func fetchCountries(completionHandler completion: @escaping (_ error: Error?, _ versions: [String]?) -> Void) {
		session.dataTask(with: url(version: "v1", "diagnosis-keys", "country")) { data, _, error in
			guard nil == error else {
				completion(error, nil)
				return
			}
			
			if let countries = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String] {
				completion(nil, countries)
			} else {
				completion(DiagnosisKeyAPIError.invalidCountries, nil)
			}
		}
		.resume()
	}
	
	
	func fetchDates(inCountry countryCode: String, completionHandler completion: @escaping (_ error: Error?, _ versions: [Date]?) -> Void) {
		session.dataTask(with: url(version: "v1", "diagnosis-keys", "country", countryCode, "date")) { data, _, error in
			guard nil == error else {
				completion(error, nil)
				return
			}
			
			if let countries = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String] {
				completion(nil, countries.compactMap { string in self.dateFormatter.date(from: string) })
			} else {
				completion(DiagnosisKeyAPIError.invalidDates, nil)
			}
		}
		.resume()
	}
	
	
	func fetchHours(for date: Date, inCountry countryCode: String, completionHandler completion: @escaping (_ error: Error?, _ hours: [Date]?) -> Void) {
		session.dataTask(with: url(version: "v1", "diagnosis-keys", "country", countryCode, "date", dateFormatter.string(from: date), "hour")) { data, _, error in
			guard nil == error else {
				completion(error, nil)
				return
			}
			
			if let hours = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [Int] {
				completion(nil, hours.compactMap { int in self.calendar.date(bySettingHour: int, minute: 0, second: 0, of: date) })
			} else {
				completion(DiagnosisKeyAPIError.invalidHours, nil)
			}
		}
		.resume()
	}
}
	
	
extension DiagnosisKeyAPI {
	func downloadDiagnosisKeys(for date: Date, inCountry countryCode: String, completionHandler completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
		session.downloadTask(with: url(version: "v1", "diagnosis-keys", "country", countryCode, "date", dateFormatter.string(from: date))) { url, _, error in
			guard nil == error else {
				completion(error, nil)
				return
			}
			completion(nil, url)
		}
		.resume()
	}
	
	
	func downloadDiagnosisKeys(for date: Date, hour: Int, inCountry countryCode: String, completionHandler completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
		session.downloadTask(with: url(version: "v1", "diagnosis-keys", "country", countryCode, "date", dateFormatter.string(from: date), "\(hour)")) { url, _, error in
			guard nil == error else {
				completion(error, nil)
				return
			}
			completion(nil, url)
		}
		.resume()
	}
}
