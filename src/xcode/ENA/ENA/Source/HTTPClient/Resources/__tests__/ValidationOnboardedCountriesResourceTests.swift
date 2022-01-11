//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import HealthCertificateToolkit
import ZIPFoundation


final class ValidationOnboardedCountriesResourceTests: CWATestCase {

	func testGIVEN_Resource_WHEN_FetchWithoutCachedData_THEN_FreshDataReturned() throws {
		// http code 200
		let expectation = expectation(description: "Expect that we got a completion")
		
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			with: .create,
			of: HealthCertificateToolkit.onboardedCountriesCBORDataFake
		))
		
		// This list has to match the one in onboardedCountriesCBORDataFake
		let expectedCountries = [Country(withCountryCodeFallback: "DE"), Country(withCountryCodeFallback: "FR")]
		
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			],
			responseData: archiveData
		)
		
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		
		var resource = ValidationOnboardedCountriesResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		serviceProvider.load(resource) { result in
			switch result {
			case let .success(model):
				XCTAssertEqual(model.countries, expectedCountries)
			case let .failure(error):
				XCTFail("Load should succeed but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_FetchWithCachedData_THEN_CashedDataReturned() {
		// http code 304
	}
	
	func testGIVEN_Resource_WHEN_HttpError404_THEN_ErrorIsReturned() {
		// http code 404
	}

	
}
