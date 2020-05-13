//
//  DiagnosisKeyManager.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation


enum DiagnosisKeyFile {
	case day(Date)
	case hour(Date)
}


class DiagnosisKeyManager {
	static let shared = DiagnosisKeyManager()
	
	
	let api: DiagnosisKeyAPI
	
	private var calendar: Calendar { Calendar.current }
	private let country: String
	
	
	init(api: DiagnosisKeyAPI = DiagnosisKeyAPI.shared, country: String = "DE") {
		self.api = api
		self.country = country
	}
}


extension DiagnosisKeyManager {
	func downloadDiagnosisKeys(files: [DiagnosisKeyFile], handler: @escaping (Error?, DiagnosisKeyFile, URL?) -> Void) {
		downloadDiagnosisKeys(files: files, handler: handler) { }
	}
	
	
	func downloadDiagnosisKeys(files: [DiagnosisKeyFile], handler: @escaping (Error?, DiagnosisKeyFile, URL?) -> Void, completionHandler completion: @escaping () -> Void) {
		let group = DispatchGroup()
		
		for file in files {
			group.enter()
			
			switch file {
			case .day(let date):
				api.downloadDiagnosisKeys(for: date, inCountry: country) { error, url in
					handler(error, file, url)
					group.leave()
				}
				
			case .hour(let date):
				let hour = api.calendar.component(.hour, from: date)
				api.downloadDiagnosisKeys(for: date, hour: hour, inCountry: country) { error, url in
					handler(error, file, url)
					group.leave()
				}
			}
		}
		
		group.notify(queue: .main, execute: completion)
	}
	
	
	func delta(from lastSync: Date, to now: Date, completion: @escaping (_ error: Error?, _ dates: [Date]?, _ hours: [Date]?, _ lastSync: Date?) -> Void) {
		fetchCurrentDates { error, dates, hours, latest in
			guard nil == error else { return }
			guard let latest = latest, latest > lastSync else { completion(nil, [], [], lastSync) ; return }
			
			let today = self.api.calendar.startOfDay(for: now)
			guard
				let yesterday = self.api.calendar.date(byAdding: .day, value: -1, to: today),
				var deltaDates = dates?.filter({ date in self.api.calendar.isDateInRange(date, from: lastSync, to: yesterday, granularity: .day, inclusive: true) }),
				let deltaHours = hours?.filter({ date in self.api.calendar.isDateInRange(date, from: lastSync > today ? lastSync : today, to: now, granularity: .hour, inclusive: true) })
				else { return }
			
			var deltaLastSync: Date
			if deltaHours.isEmpty {
				// Technically this should never happen
				deltaDates.append(today)
				deltaLastSync = today
			} else {
				// swiftlint:disable:next force_unwrapping
				deltaLastSync = deltaHours.last!
			}
			
			completion(nil, deltaDates, deltaHours, deltaLastSync)
		}
	}
	
	
	func fetchCurrentDates(completionHandler completion: @escaping (_ error: Error?, _ dates: [Date]?, _ hours: [Date]?, _ latest: Date?) -> Void) {
		self.api.fetchDates(inCountry: "DE") { error, dates in
			guard nil == error else { completion(error, nil, nil, nil) ; return }
			guard let date = dates?.last else { completion(DiagnosisKeyAPIError.invalidDates, nil, nil, nil) ; return }
			
			self.api.fetchHours(for: date, inCountry: "DE") { error, hours in
				guard nil == error else { completion(error, nil, nil, nil) ; return }
				guard let latest = hours?.last else { completion(DiagnosisKeyAPIError.invalidHours, nil, nil, nil) ; return }
				
				completion(nil, dates, hours, latest)
			}
		}
	}
}


private extension Calendar {
	indirect enum CompareOperator {
		case equal
		case less
		case lessOrEqual
		case greater
		case greaterOrEqual
		case not(CompareOperator)
	}
	
	
	func compare(_ left: Date, to right: Date, granularity: Component, operator comparisonOperator: CompareOperator) -> Bool {
		let comparison = self.compare(left, to: right, toGranularity: granularity)
		
		switch comparisonOperator {
		case .equal:
			return comparison == .orderedSame
		case .less:
			return comparison == .orderedAscending
		case .lessOrEqual:
			return comparison != .orderedDescending
		case .greater:
			return comparison == .orderedDescending
		case .greaterOrEqual:
			return comparison != .orderedAscending
		case .not(let invertedOperator):
			return !self.compare(left, to: right, granularity: granularity, operator: invertedOperator)
		}
	}
	
	
	func isDateInRange(_ date: Date, from: Date, to: Date, granularity: Component, inclusive: Bool = true) -> Bool {
		return self.isDateInRange(date, from: from, to: to, granularity: granularity, fromInclusive: inclusive, toInclusive: inclusive)
	}
	
	
	func isDateInRange(_ date: Date, from: Date, to: Date, granularity: Component, fromInclusive: Bool = true, toInclusive: Bool = true) -> Bool {
		let fromComparison = self.compare(date, to: from, granularity: granularity, operator: fromInclusive ? .greaterOrEqual : .greater)
		let toComparison = self.compare(date, to: to, granularity: granularity, operator: toInclusive ? .lessOrEqual : .less)
		return fromComparison && toComparison
	}
}
