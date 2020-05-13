//
//  KeyRetrievalTests.swift
//  ENATests
//
//  Created by Marc-Peter Eisinger on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//


import XCTest
@testable import ENA


class DiagnosisKeyAPITests: XCTestCase {
	let baseUrl: URL! = URL(string: "http://distribution-mock-cwa-server.apps.p006.otc.mcs-paas.io")
	
	
	func testBaseUrl() {
		XCTAssertNotNil(baseUrl, "Base URL must not be nil!")
		XCTAssertNotNil(baseUrl.scheme, "Base URL scheme must not be nil!")
		XCTAssertNotNil(baseUrl.host, "Base URL host must not be nil!")
	}
	
	
	func testApiV1() {
		let expectation = self.expectation(description: "Check availability of API v1 endpoint.")
		
		DiagnosisKeyAPI.shared.fetchApiVersions { error, versions in
			XCTAssertNil(error, error?.localizedDescription ?? "")
			XCTAssertNotNil(versions, "'versions' must not be nil!")
			XCTAssertTrue(versions?.contains("v1") ?? false, "Version identifier v1 missing.")
			
			print("API Versions:", versions!)
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 10)
	}
	
	
	func testCountries() {
		let expectation = self.expectation(description: "Check countries endpoint.")
		
		DiagnosisKeyAPI.shared.fetchCountries { error, countries in
			XCTAssertNil(error, error?.localizedDescription ?? "")
			XCTAssertNotNil(countries, "'countries' must not be nil!")
			XCTAssertTrue(countries?.contains("DE") ?? false, "Country identifier DE missing.")
			
			print("Countries:", countries!)
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 10)
	}
	
	
	func testDates() {
		let expectation = self.expectation(description: "Check dates endpoint.")
		
		DiagnosisKeyAPI.shared.fetchDates(inCountry: "DE") { error, dates in
			XCTAssertNil(error, error?.localizedDescription ?? "")
			XCTAssertNotNil(dates, "'dates' must not be nil!")
			XCTAssertTrue(dates?.count ?? 0 > 0, "Response did not contain any dates.")
			
			print("Dates:", dates!)
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 10)
	}
	
	
	func testHours() {
		let expectation = self.expectation(description: "Check hours endpoint.")
		
		DiagnosisKeyAPI.shared.fetchDates(inCountry: "DE") { error, hours in
			XCTAssertNil(error, error?.localizedDescription ?? "")
			XCTAssertNotNil(hours, "'hours' must not be nil!")
			XCTAssertTrue(hours?.count ?? 0 > 0, "Response did not contain any hours.")
			
			print("Hours:", hours!)
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 10)
	}
	
	
	func testDailyDiagnosisKeys() {
		let expectation = self.expectation(description: "Check daily diagnosis keys endpoint.")
		
		let date = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2020, month: 5, day: 10).date!
		
		DiagnosisKeyAPI.shared.downloadDiagnosisKeys(for: date, inCountry: "DE") { error, url in
			XCTAssertNil(error, error?.localizedDescription ?? "")
			XCTAssertNotNil(url, "'url' must not be nil!")
			
			print("Temporary URL:", url!)
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 10)
	}
	
	
	func testHourlyDiagnosisKeys() {
		let expectation = self.expectation(description: "Check hourly diagnosis keys endpoint.")
		
		let date = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2020, month: 5, day: 10).date!
		
		DiagnosisKeyAPI.shared.downloadDiagnosisKeys(for: date, hour:5, inCountry: "DE") { error, url in
			XCTAssertNil(error, error?.localizedDescription ?? "")
			XCTAssertNotNil(url, "'url' must not be nil!")
			
			print("Temporary URL:", url!)
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 10)
	}
}

