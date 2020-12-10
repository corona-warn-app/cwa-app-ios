//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCoordinatorModelTests: XCTestCase {

	func testSymptomsOptionYesSelected() {
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService()
		)

		model.symptomsOptionSelected(.yes)

		XCTAssertTrue(model.shouldShowSymptomsOnsetScreen)
	}

	func testSymptomsOptionNoSelected() {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		model.symptomsOptionSelected(.no)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .nonSymptomatic)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOptionPreferNotToSaySelected() {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		model.symptomsOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .noInformation)

		waitForExpectations(timeout: .short)
	}

	// MARK: -

	func testSymptomsOnsetOptionExactDateSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		let yesterday = try XCTUnwrap(Calendar.gregorian().date(byAdding: .day, value: -1, to: Date()))

		model.symptomsOnsetOptionSelected(.exactDate(yesterday))

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .daysSinceOnset(1))

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionLastSevenDaysSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		model.symptomsOnsetOptionSelected(.lastSevenDays)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .lastSevenDays)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionOneToTwoWeeksAgoSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		model.symptomsOnsetOptionSelected(.oneToTwoWeeksAgo)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .oneToTwoWeeksAgo)


		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionMoreThanTwoWeeksAgoSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		model.symptomsOnsetOptionSelected(.moreThanTwoWeeksAgo)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .moreThanTwoWeeksAgo)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionPreferNotToSaySelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		model.symptomsOnsetOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .symptomaticWithUnknownOnset)

		waitForExpectations(timeout: .short)
	}

	// MARK: -

	func testSuccessfulSubmit() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(nil)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.submitExposure(
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
			completion(.noKeysCollected)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.submitExposure(
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
			exposureSubmissionService: exposureSubmissionService
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

		model.submitExposure(
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
			exposureSubmissionService: exposureSubmissionService
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError is called")

		model.submitExposure(
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
			exposureSubmissionService: exposureSubmissionService
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
			exposureSubmissionService: exposureSubmissionService
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
