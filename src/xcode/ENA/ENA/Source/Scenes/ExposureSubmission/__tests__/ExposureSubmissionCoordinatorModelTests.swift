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

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionCoordinatorModelTests: XCTestCase {

	func testExposureSubmissionServiceHasRegistrationToken() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.hasRegistrationTokenCallback = { true }

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		XCTAssertTrue(model.exposureSubmissionServiceHasRegistrationToken)
	}

	func testExposureSubmissionServiceHasNoRegistrationToken() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.hasRegistrationTokenCallback = { false }

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		XCTAssertFalse(model.exposureSubmissionServiceHasRegistrationToken)
	}

	// MARK: -

	func testCheckStateAndLoadCountriesSupportedCountriesLoadSucceeds() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.preconditionsCallback = { ExposureManagerState(authorized: true, enabled: true, status: .active) }
		exposureSubmissionService.submitExposureCallback = { _, visitedCountries, _ in
			XCTAssertEqual(visitedCountries, [Country(countryCode: "DE"), Country(countryCode: "IT"), Country(countryCode: "ES")])
		}

		var config = SAP_Internal_ApplicationConfiguration()
		config.supportedCountries = ["DE", "IT", "ES"]

		let provider = CachedAppConfigurationMock(
			appConfigurationResult: .success(config)
		)

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

		model.checkStateAndLoadCountries(
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

	func testCheckStateAndLoadCountriesSupportedCountriesLoadEmpty() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.preconditionsCallback = { ExposureManagerState(authorized: true, enabled: true, status: .active) }
		exposureSubmissionService.submitExposureCallback = { _, visitedCountries, _ in
			XCTAssertEqual(visitedCountries, [Country(countryCode: "DE")])
		}

		var config = SAP_Internal_ApplicationConfiguration()
		config.supportedCountries = []

		let provider = CachedAppConfigurationMock(
			appConfigurationResult: .success(config)
		)

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

		model.checkStateAndLoadCountries(
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

	func testCheckStateAndLoadCountriesSupportedCountriesLoadFails() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.preconditionsCallback = { ExposureManagerState(authorized: true, enabled: true, status: .active) }
		exposureSubmissionService.submitExposureCallback = { _, visitedCountries, _ in
			XCTAssert(visitedCountries.isEmpty)
		}

		let provider = CachedAppConfigurationMock(
			appConfigurationResult: .failure(CachedAppConfiguration.CacheError.dataFetchError(message: "fake"))
		)

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

		model.checkStateAndLoadCountries(
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
		XCTAssert(model.supportedCountries.isEmpty)
	}

	func testCheckStateAndLoadCountriesStateCheckFails() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.preconditionsCallback = { ExposureManagerState(authorized: false, enabled: false, status: .unknown) }

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let isLoadingExpectation = expectation(description: "isLoading is not called")
		isLoadingExpectation.isInverted = true

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError is called")

		model.checkStateAndLoadCountries(
			isLoading: { _ in isLoadingExpectation.fulfill() },
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { error in
				XCTAssertEqual(error, .enNotEnabled)
				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
		XCTAssert(model.supportedCountries.isEmpty)
	}

	// MARK: -

	func testSymptomsOptionYesSelected() {
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOptionSelected(.yes)

		XCTAssertTrue(model.shouldShowSymptomsOnsetScreen)
	}

	func testSymptomsOptionNoSelected() {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .nonSymptomatic)

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOptionSelected(.no)

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOptionPreferNotToSaySelected() {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .noInformation)

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)

		waitForExpectations(timeout: .short)
	}

	// MARK: -

	func testSymptomsOnsetOptionExactDateSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .daysSinceOnset(1))

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let yesterday = try XCTUnwrap(Calendar.gregorian().date(byAdding: .day, value: -1, to: Date()))

		model.symptomsOnsetOptionSelected(.exactDate(yesterday))

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionLastSevenDaysSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .lastSevenDays)

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOnsetOptionSelected(.lastSevenDays)

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionOneToTwoWeeksAgoSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .oneToTwoWeeksAgo)

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOnsetOptionSelected(.oneToTwoWeeksAgo)

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionMoreThanTwoWeeksAgoSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .moreThanTwoWeeksAgo)

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOnsetOptionSelected(.moreThanTwoWeeksAgo)

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionPreferNotToSaySelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { symptomsOnset, _, _ in
			XCTAssertEqual(symptomsOnset, .symptomaticWithUnknownOnset)

			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		model.symptomsOnsetOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.warnOthersConsentGiven(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		waitForExpectations(timeout: .short)
	}

	// MARK: -

	func testSuccessfulSubmit() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _, _, completion in
			completion(nil)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
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
		exposureSubmissionService.submitExposureCallback = { _, _, completion in
			completion(.noKeys)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
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
		exposureSubmissionService.submitExposureCallback = { _, _, completion in
			completion(.notAuthorized)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
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
		exposureSubmissionService.submitExposureCallback = { _, _, completion in
			completion(.internal)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
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

	func testGetTestResultSucceeds() {
		let expectedTestResult: TestResult = .positive

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.getTestResultCallback = { completion in
			completion(.success(expectedTestResult))
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.getTestResults(
			for: .guid(""),
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { testResult in
				XCTAssertEqual(testResult, expectedTestResult)

				onSuccessExpectation.fulfill()
			},
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetTestResultFails() {
		let expectedError: ExposureSubmissionError = .unknown

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.getTestResultCallback = { completion in
			completion(.failure(expectedError))
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError is called")

		model.getTestResults(
			for: .guid(""),
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in onSuccessExpectation.fulfill() },
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

}
