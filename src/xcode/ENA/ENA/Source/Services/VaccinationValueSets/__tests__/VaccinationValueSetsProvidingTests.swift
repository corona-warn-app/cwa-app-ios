////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class VaccinationValueSetsProvidingTests: CWATestCase {
	
	private var subscriptions = [AnyCancellable]()
	
	func testFetchVaccinationValueSets() {
		let fetchedFromClientExpectation = expectation(description: "Vaccination Value Sets fetched from client")
		fetchedFromClientExpectation.expectedFulfillmentCount = 1
		
		let store = MockTestStore()
		XCTAssertNil(store.vaccinationCertificateValueDataSets)
		
		let client = CachingHTTPClientMock()
		client.fetchVaccinationValueSets(etag: "fake") { result in
			switch result {
			case .success(let response):
				XCTAssertNotNil(response.eTag)
				XCTAssertNotNil(response.valueSets)
				XCTAssertNotNil(response.timestamp)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			fetchedFromClientExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testVaccinationValueSetsProviding() throws {
		let valueReceived = expectation(description: "Value received")
		valueReceived.expectedFulfillmentCount = 1
		
		let store = MockTestStore()
		let client = CachingHTTPClientMock()
		let provider = VaccinationValueSetsProvider(client: client, store: store)
		provider.latestVaccinationCertificateValueSets()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail(error.localizedDescription)
				}
			}, receiveValue: { valueSets in
				XCTAssertNotNil(valueSets)
				valueReceived.fulfill()
			})
			.store(in: &subscriptions)
		
		waitForExpectations(timeout: .short)
	}
	
	func testVaccinationValueSetsProvidingHTTPErrors() throws {
		let store = MockTestStore()
		let client = CachingHTTPClientMock()
		let expectedError = URLSessionError.serverError(503)
		client.onFetchVaccinationValueSets = { _, completeWith in
			// fake a broken backend
			completeWith(.failure(expectedError))
		}
		
		let provider = VaccinationValueSetsProvider(client: client, store: store)
		provider.latestVaccinationCertificateValueSets()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTAssertEqual(error.localizedDescription, expectedError.errorDescription)
				}
			}, receiveValue: { _ in
				XCTFail("Did not expect a value")
			})
			.store(in: &subscriptions)
	}
	
	func testVaccinationValueSetsProvidingHTTP304() throws {
		let valueNotChangedExpectation = expectation(description: "Value not changed")
		valueNotChangedExpectation.expectedFulfillmentCount = 2
		
		let store = MockTestStore()
		store.vaccinationCertificateValueDataSets = VaccinationValueDataSets(
			lastValueDataSetsETag: "fake",
			lastValueDataSetsFetchDate: try XCTUnwrap(301.secondsAgo),
			valueDataSets: CachingHTTPClientMock.staticVaccinationValueSets
		)
		// Fake, backend returns HTTP 304
		let client = CachingHTTPClientMock()
		client.onFetchVaccinationValueSets = { _, completeWith in
			let error = URLSessionError.notModified
			completeWith(.failure(error))
			valueNotChangedExpectation.fulfill()
		}
		
		let provider = VaccinationValueSetsProvider(client: client, store: store)
		provider.latestVaccinationCertificateValueSets()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail("Expected a no error, got: \(error)")
				}
			}, receiveValue: { value in
				XCTAssertNotNil(value)
				valueNotChangedExpectation.fulfill()
			})
			.store(in: &subscriptions)
		
		waitForExpectations(timeout: .medium)
	}
}
