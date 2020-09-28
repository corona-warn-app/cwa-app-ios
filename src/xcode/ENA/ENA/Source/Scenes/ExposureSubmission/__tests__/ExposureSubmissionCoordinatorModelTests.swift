//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
@testable import ENA

class ExposureSubmissionCoordinatorModelTests: XCTestCase {

	// default provider for a static app configuration
	let configProvider = CachedAppConfiguration(client: CachingHTTPClientMock(), store: MockTestStore())

	override func setUpWithError() throws {
		// uses a common database!
		let store = MockTestStore()
		store.appConfig = nil
		store.lastAppConfigETag = nil
	}

	override func tearDownWithError() throws {
		// uses a common database!
		let store = MockTestStore()
		store.appConfig = nil
		store.lastAppConfigETag = nil
	}

	func testExposureSubmissionServiceHasRegistrationToken() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.hasRegistrationTokenCallback = { true }

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		XCTAssertTrue(model.exposureSubmissionServiceHasRegistrationToken)
	}

	func testExposureSubmissionServiceHasNoRegistrationToken() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.hasRegistrationTokenCallback = { false }

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		XCTAssertFalse(model.exposureSubmissionServiceHasRegistrationToken)
	}

	func testSymptomsOptionYesSelected() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(nil)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		let expectedIsLoadingValues = [Bool]()
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is not called")
		isLoadingExpectation.isInverted = true

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.symptomsOptionSelected(
			selectedSymptomsOption: .yes,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

		XCTAssertTrue(model.shouldShowSymptomsOnsetScreen)
	}

	func testSymptomsOptionNoOrPreferNotToSaySelectedSupportedCountriesLoadSucceeds() {
		let symptomOptions: [ExposureSubmissionSymptomsViewController.SymptomsOption] = [.no, .preferNotToSay]
		for symptomOption in symptomOptions {
			let exposureSubmissionService = MockExposureSubmissionService()
			exposureSubmissionService.submitExposureCallback = { completion in
				completion(nil)
			}

			let client = CachingHTTPClientMock()
			client.onFetchAppConfiguration = { _, completeWith in
				var config = SAP_ApplicationConfiguration()
				config.supportedCountries = ["DE", "IT", "ES"]
				completeWith(.success(AppConfigurationFetchingResponse(config)))
			}
			let provider = CachedAppConfiguration(client: client, store: MockTestStore())

			let model = ExposureSubmissionCoordinatorModel(
				exposureSubmissionService: exposureSubmissionService,
				appConfigurationProvider: provider
			)

			let expectedIsLoadingValues = [true, false]
			var isLoadingValues = [Bool]()

			let isLoadingExpectation = expectation(description: "isLoading is called twice")
			isLoadingExpectation.expectedFulfillmentCount = 2

			let onSuccessExpectation = expectation(description: "onSuccess is called")

			let onErrorExpectation = expectation(description: "onError is not called")
			onErrorExpectation.isInverted = true

			model.symptomsOptionSelected(
				selectedSymptomsOption: symptomOption,
				isLoading: {
					isLoadingValues.append($0)
					isLoadingExpectation.fulfill()
				},
				onSuccess: { onSuccessExpectation.fulfill() },
				onError: { _ in onErrorExpectation.fulfill() }
			)

			waitForExpectations(timeout: .short)
			XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

			XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
			XCTAssertEqual(model.supportedCountries, [Country(countryCode: "DE"), Country(countryCode: "IT"), Country(countryCode: "ES")])
		}
	}

	func testSymptomsOptionNoOrPreferNotToSaySelectedSupportedCountriesLoadEmpty() {
		let symptomOptions: [ExposureSubmissionSymptomsViewController.SymptomsOption] = [.no, .preferNotToSay]
		for symptomOption in symptomOptions {
			let exposureSubmissionService = MockExposureSubmissionService()
			exposureSubmissionService.submitExposureCallback = { completion in
				completion(nil)
			}

			let client = CachingHTTPClientMock()
			client.onFetchAppConfiguration = { _, completeWith in
				var config = SAP_ApplicationConfiguration()
				config.supportedCountries = []
				completeWith(.success(AppConfigurationFetchingResponse(config)))
			}
			let provider = CachedAppConfiguration(client: client, store: MockTestStore())

			let model = ExposureSubmissionCoordinatorModel(
				exposureSubmissionService: exposureSubmissionService,
				appConfigurationProvider: provider
			)

			let expectedIsLoadingValues = [true, false]
			var isLoadingValues = [Bool]()

			let isLoadingExpectation = expectation(description: "isLoading is called twice")
			isLoadingExpectation.expectedFulfillmentCount = 2

			let onSuccessExpectation = expectation(description: "onSuccess is called")

			let onErrorExpectation = expectation(description: "onError is not called")
			onErrorExpectation.isInverted = true

			model.symptomsOptionSelected(
				selectedSymptomsOption: symptomOption,
				isLoading: {
					isLoadingValues.append($0)
					isLoadingExpectation.fulfill()
				},
				onSuccess: { onSuccessExpectation.fulfill() },
				onError: { _ in onErrorExpectation.fulfill() }
			)

			waitForExpectations(timeout: .short)
			XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

			XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
			XCTAssertEqual(model.supportedCountries, [Country(countryCode: "DE")])
		}
	}

	func testSymptomsOptionNoOrPreferNotToSaySelectedSupportedCountriesLoadFails() {
		let symptomOptions: [ExposureSubmissionSymptomsViewController.SymptomsOption] = [.no, .preferNotToSay]
		for symptomOption in symptomOptions {
			let exposureSubmissionService = MockExposureSubmissionService()
			exposureSubmissionService.submitExposureCallback = { completion in
				completion(nil)
			}

			// Simulate an empty cache and broken network
			let client = CachingHTTPClientMock()
			client.onFetchAppConfiguration = { _, completeWith in
				completeWith(.failure(CachedAppConfiguration.CacheError.dataFetchError(message: "fake")))
			}
			let store = MockTestStore()
			store.appConfig = nil
			store.lastAppConfigETag = nil
			let provider = CachedAppConfiguration(client: client, store: store)

			let model = ExposureSubmissionCoordinatorModel(
				exposureSubmissionService: exposureSubmissionService,
				appConfigurationProvider: provider
			)

			let expectedIsLoadingValues = [true, false]
			var isLoadingValues = [Bool]()

			let isLoadingExpectation = expectation(description: "isLoading is called twice")
			isLoadingExpectation.expectedFulfillmentCount = 2

			let onSuccessExpectation = expectation(description: "onSuccess is not called")
			onSuccessExpectation.isInverted = true

			let onErrorExpectation = expectation(description: "onError is called")

			model.symptomsOptionSelected(
				selectedSymptomsOption: symptomOption,
				isLoading: {
					isLoadingValues.append($0)
					isLoadingExpectation.fulfill()
				},
				onSuccess: { onSuccessExpectation.fulfill() },
				onError: { _ in onErrorExpectation.fulfill() }
			)

			waitForExpectations(timeout: .short)
			XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

			XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
			XCTAssertEqual(model.supportedCountries, [])
		}
	}

	func testSymptomsOnsetOptionsSelectedSupportedCountriesLoadSucceeds() {
		let symptomsOnsetOptions: [ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption] = [.exactDate(Date()), .lastSevenDays, .oneToTwoWeeksAgo, .moreThanTwoWeeksAgo, .preferNotToSay]
		for symptomsOnsetOption in symptomsOnsetOptions {
			let exposureSubmissionService = MockExposureSubmissionService()
			exposureSubmissionService.submitExposureCallback = { completion in
				completion(nil)
			}

			let client = CachingHTTPClientMock()
			client.onFetchAppConfiguration = { _, completeWith in
				var config = SAP_ApplicationConfiguration()
				config.supportedCountries = ["DE", "IT", "ES"]
				completeWith(.success(AppConfigurationFetchingResponse(config)))
			}
			let provider = CachedAppConfiguration(client: client, store: MockTestStore())

			let model = ExposureSubmissionCoordinatorModel(
				exposureSubmissionService: exposureSubmissionService,
				appConfigurationProvider: provider
			)

			let expectedIsLoadingValues = [true, false]
			var isLoadingValues = [Bool]()

			let isLoadingExpectation = expectation(description: "isLoading is called twice")
			isLoadingExpectation.expectedFulfillmentCount = 2

			let onSuccessExpectation = expectation(description: "onSuccess is called")

			let onErrorExpectation = expectation(description: "onError is not called")
			onErrorExpectation.isInverted = true

			model.symptomsOnsetOptionSelected(
				selectedSymptomsOnsetOption: symptomsOnsetOption,
				isLoading: {
					isLoadingValues.append($0)
					isLoadingExpectation.fulfill()
				},
				onSuccess: { onSuccessExpectation.fulfill() },
				onError: { _ in onErrorExpectation.fulfill() }
			)

			waitForExpectations(timeout: .short)
			XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

			XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
			XCTAssertEqual(model.supportedCountries, [Country(countryCode: "DE"), Country(countryCode: "IT"), Country(countryCode: "ES")])
		}
	}

	func testSymptomsOnsetOptionsSelectedSupportedCountriesLoadEmpty() {
		let symptomsOnsetOptions: [ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption] = [.exactDate(Date()), .lastSevenDays, .oneToTwoWeeksAgo, .moreThanTwoWeeksAgo, .preferNotToSay]
		for symptomsOnsetOption in symptomsOnsetOptions {
			let exposureSubmissionService = MockExposureSubmissionService()
			exposureSubmissionService.submitExposureCallback = { completion in
				completion(nil)
			}

			let client = CachingHTTPClientMock()
			let provider = CachedAppConfiguration(client: client, store: MockTestStore())
			client.onFetchAppConfiguration = { _, completeWith in
				var config = SAP_ApplicationConfiguration()
				config.supportedCountries = []
				completeWith(.success(AppConfigurationFetchingResponse(config)))
			}

			let model = ExposureSubmissionCoordinatorModel(
				exposureSubmissionService: exposureSubmissionService,
				appConfigurationProvider: provider
			)

			let expectedIsLoadingValues = [true, false]
			var isLoadingValues = [Bool]()

			let isLoadingExpectation = expectation(description: "isLoading is called twice")
			isLoadingExpectation.expectedFulfillmentCount = 2

			let onSuccessExpectation = expectation(description: "onSuccess is called")

			let onErrorExpectation = expectation(description: "onError is not called")
			onErrorExpectation.isInverted = true

			model.symptomsOnsetOptionSelected(
				selectedSymptomsOnsetOption: symptomsOnsetOption,
				isLoading: {
					isLoadingValues.append($0)
					isLoadingExpectation.fulfill()
				},
				onSuccess: { onSuccessExpectation.fulfill() },
				onError: { _ in onErrorExpectation.fulfill() }
			)

			waitForExpectations(timeout: .short)
			XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

			XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
			XCTAssertEqual(model.supportedCountries, [Country(countryCode: "DE")])
		}
	}

	func testSymptomsOnsetOptionsSelectedSupportedCountriesLoadFails() {
		let symptomsOnsetOptions: [ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption] = [.exactDate(Date()), .lastSevenDays, .oneToTwoWeeksAgo, .moreThanTwoWeeksAgo, .preferNotToSay]
		for symptomsOnsetOption in symptomsOnsetOptions {
			let exposureSubmissionService = MockExposureSubmissionService()
			exposureSubmissionService.submitExposureCallback = { completion in
				completion(nil)
			}

			// Simulate an empty cache and broken network
			let client = CachingHTTPClientMock()
			client.onFetchAppConfiguration = { _, completeWith in
				completeWith(.failure(CachedAppConfiguration.CacheError.dataFetchError(message: "fake")))
			}
			let store = MockTestStore()
			store.appConfig = nil
			store.lastAppConfigETag = nil
			let provider = CachedAppConfiguration(client: client, store: store)

			let model = ExposureSubmissionCoordinatorModel(
				exposureSubmissionService: exposureSubmissionService,
				appConfigurationProvider: provider
			)

			let expectedIsLoadingValues = [true, false]
			var isLoadingValues = [Bool]()

			let isLoadingExpectation = expectation(description: "isLoading is called twice")
			isLoadingExpectation.expectedFulfillmentCount = 2

			let onSuccessExpectation = expectation(description: "onSuccess is not called")
			onSuccessExpectation.isInverted = true

			let onErrorExpectation = expectation(description: "onError is called")

			model.symptomsOnsetOptionSelected(
				selectedSymptomsOnsetOption: symptomsOnsetOption,
				isLoading: {
					isLoadingValues.append($0)
					isLoadingExpectation.fulfill()
				},
				onSuccess: { onSuccessExpectation.fulfill() },
				onError: { _ in onErrorExpectation.fulfill() }
			)

			waitForExpectations(timeout: .short)
			XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)

			XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
			XCTAssertEqual(model.supportedCountries, [])
		}
	}

	func testSuccessfulSubmit() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(nil)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.warnOthersConsentGiven(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testSuccessfulSubmitWithoutKeys() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.noKeys)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.warnOthersConsentGiven(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testFailingSubmitWithNotAuthorizedError() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.notAuthorized)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		// .notAuthorized should not trigger an error
		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.warnOthersConsentGiven(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testFailingSubmitWithInternalError() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.internal)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: configProvider
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError is called")

		model.warnOthersConsentGiven(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

}
