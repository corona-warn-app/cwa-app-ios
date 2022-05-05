//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

final class HTTPClientDaysAndHoursTests: CWATestCase {
	let binFileSize = 501
	let sigFileSize = 144
	let mockUrl = URL(staticString: "http://example.com")
	let tan = "1234"

	private var keys: [ENTemporaryExposureKey] {
		let key = ENTemporaryExposureKey()
		key.keyData = Data(bytes: [1, 2, 3], count: 3)
		key.rollingPeriod = 1337
		key.rollingStartNumber = 42
		key.transmissionRiskLevel = 8

		return [key]
	}

	func testAvailableDays_Success() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("[\"2020-05-01\", \"2020-05-02\"]".utf8)
		)

		let expectation = self.expectation(
			description: "expect successful result"
		)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableDaysResource(country: "IT")

		restServiceProvider.load(resource) { result in
			switch result {
			case let .success(days):
				XCTAssertEqual(
					days,
					["2020-05-01", "2020-05-02"]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yiled an error like \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testAvailableDays_StatusCodeNotAccepted() {
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data(
				"""
				["2020-05-01", "2020-05-02"]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect error result"
		)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableDaysResource(country: "IT")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never yield success")
			case .failure:
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchDay_Success() throws {
		let url = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil))
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let resource = FetchDayResource(day: "2020-05-01", country: "IT", signatureVerifier: MockVerifier())
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
			defer { successExpectation.fulfill() }
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)
			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchDay_InvalidPackage() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let resource = FetchDayResource(day: "2020-05-01", country: "IT")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("An invalid server response should not result in success!")
			case let .failure(error):
				switch error {
				case .resourceError:
					break
				default:
					XCTFail("Incorrect error type \(error) received, expected .resourceError")
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}
	
	private func assertPackageFormat(for response: PackageDownloadResponse) {
		// Packages for key download are never empty
		XCTAssertFalse(response.isEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package?.bin.count, binFileSize)
		XCTAssertEqual(response.package?.signature.count, sigFileSize)
	}
}
