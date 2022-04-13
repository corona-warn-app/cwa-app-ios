//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class FamilyMemberCoronaTestsViewModelTest: CWATestCase {

	func testNumberOfSections() throws {
		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertEqual(viewModel.numberOfSections, 1)
	}

	func testNumberOfRowsWithEmptyEntriesSection() throws {
		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertEqual(
			viewModel.numberOfRows(in: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue),
			0
		)
	}

	func testNumberOfRowsWithNonEmptyEntriesSection() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock()), .pcr(.mock()), .antigen(.mock())
		]

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertEqual(
			viewModel.numberOfRows(in: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue),
			3
		)
	}

	func testIsEmptyOnEmptyEntriesSection() throws {
		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [.pcr(.mock())]

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForCoronaTestsSection() throws {
		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertTrue(
			viewModel.canEditRow(
				at: IndexPath(row: 0, section: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue)
			)
		)
	}

	func testCellModels() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "1")),
			.pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 2), qrCodeHash: "2")),
			.antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "3"))
		]

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		XCTAssertEqual(
			viewModel.coronaTestCellModels[0].name,
			"asdf"
		)
		XCTAssertEqual(
			viewModel.coronaTestCellModels[1].name,
			"qwer"
		)
		XCTAssertEqual(
			viewModel.coronaTestCellModels[2].name,
			"zxcv"
		)
	}

	func testTriggerReloadIsSetIfTestIsAdded() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "1")),
			.pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 2), qrCodeHash: "2")),
			.antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "3"))
		]

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		let triggerReloadExpectation = expectation(description: "triggerReload published")
		triggerReloadExpectation.expectedFulfillmentCount = 2

		var receivedTriggerReloadValues = [Bool]()
		let subscription = viewModel.triggerReload
			.sink {
				receivedTriggerReloadValues.append($0)
				triggerReloadExpectation.fulfill()
			}

		familyMemberCoronaTestService.coronaTests.value.append(.antigen(.mock(displayName: "uiop", sampleCollectionDate: Date(timeIntervalSinceNow: 0), qrCodeHash: "4")))

		waitForExpectations(timeout: .medium)

		// The initial update already publishes the first true value
		XCTAssertEqual(receivedTriggerReloadValues, [true, true])

		subscription.cancel()
	}

	func testTriggerReloadIsSetIfTestIsRemoved() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "1")),
			.pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 2), qrCodeHash: "2")),
			.antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "3"))
		]

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		let triggerReloadExpectation = expectation(description: "triggerReload published")
		triggerReloadExpectation.expectedFulfillmentCount = 2

		var receivedTriggerReloadValues = [Bool]()
		let subscription = viewModel.triggerReload
			.sink {
				receivedTriggerReloadValues.append($0)
				triggerReloadExpectation.fulfill()
			}

		familyMemberCoronaTestService.coronaTests.value.remove(at: 0)

		waitForExpectations(timeout: .medium)

		// The initial update already publishes the first true value
		XCTAssertEqual(receivedTriggerReloadValues, [true, true])

		subscription.cancel()
	}

	func testTriggerReloadIsNotSetIfTestIsAltered() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "1")),
			.pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 2), qrCodeHash: "2")),
			.antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "3"))
		]

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		let triggerReloadExpectation = expectation(description: "triggerReload published")
		triggerReloadExpectation.expectedFulfillmentCount = 1

		var receivedTriggerReloadValues = [Bool]()
		let subscription = viewModel.triggerReload
			.sink {
				receivedTriggerReloadValues.append($0)
				triggerReloadExpectation.fulfill()
			}

		// qrCodeHashes stay the same, only names are altered
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf2", registrationDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "1")),
			.pcr(.mock(displayName: "qwer2", registrationDate: Date(timeIntervalSinceNow: 2), qrCodeHash: "2")),
			.antigen(.mock(displayName: "zxcv2", sampleCollectionDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "3"))
		]

		waitForExpectations(timeout: .medium)

		// The initial update already publishes the first true value
		XCTAssertEqual(receivedTriggerReloadValues, [true])

		subscription.cancel()
	}

	func testDidTapCoronaTestCell() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "pcrPending", registrationDate: Date(timeIntervalSinceNow: 0), qrCodeHash: "0", testResult: .pending)),
			.pcr(.mock(displayName: "pcrNegative", registrationDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "1", testResult: .negative)),
			.pcr(.mock(displayName: "pcrPositive", registrationDate: Date(timeIntervalSinceNow: 2), qrCodeHash: "2", testResult: .positive)),
			.pcr(.mock(displayName: "pcrInvalid", registrationDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "3", testResult: .invalid)),
			.pcr(.mock(displayName: "pcrExpired", registrationDate: Date(timeIntervalSinceNow: 4), qrCodeHash: "4", testResult: .expired)),
			.antigen(.mock(displayName: "antigenPending", sampleCollectionDate: Date(timeIntervalSinceNow: 5), qrCodeHash: "5", testResult: .pending, isOutdated: false)),
			.antigen(.mock(displayName: "antigenNegative", sampleCollectionDate: Date(timeIntervalSinceNow: 6), qrCodeHash: "6", testResult: .negative, isOutdated: false)),
			.antigen(.mock(displayName: "antigenPositive", sampleCollectionDate: Date(timeIntervalSinceNow: 7), qrCodeHash: "7", testResult: .positive, isOutdated: false)),
			.antigen(.mock(displayName: "antigenInvalid", sampleCollectionDate: Date(timeIntervalSinceNow: 8), qrCodeHash: "8", testResult: .invalid, isOutdated: false)),
			.antigen(.mock(displayName: "antigenExpired", sampleCollectionDate: Date(timeIntervalSinceNow: 9), qrCodeHash: "9", testResult: .expired, isOutdated: false)),
			.antigen(.mock(displayName: "antigenOutdated", sampleCollectionDate: Date(timeIntervalSinceNow: 10), qrCodeHash: "10", testResult: .negative, isOutdated: true))
		]

		// Expired and outdated tests should be filtered out
		let expectedDisplayNames = ["pcrPending", "pcrNegative", "pcrPositive", "pcrInvalid", "antigenPending", "antigenNegative", "antigenPositive", "antigenInvalid"]

		let cellTapExpectation = expectation(description: "onCoronaTestCellTap called")
		cellTapExpectation.expectedFulfillmentCount = expectedDisplayNames.count

		var receivedDisplayNames = [String]()
		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: {
				receivedDisplayNames.append($0.displayName)
				cellTapExpectation.fulfill()
			},
			onLastDeletion: { }
		)

		for index in familyMemberCoronaTestService.coronaTests.value.indices.reversed() {
			viewModel.didTapCoronaTestCell(
				at: IndexPath(row: index, section: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue)
			)
		}

		waitForExpectations(timeout: .medium)


		XCTAssertEqual(receivedDisplayNames, expectedDisplayNames)
	}

	func testDidTapCoronaTestCellButton() throws {
		let testToRemove: FamilyMemberCoronaTest = .pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "1"))

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 0), qrCodeHash: "0")),
			testToRemove,
			.antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "3"))
		]

		let moveTestToBinExpectation = expectation(description: "onCoronaTestCellTap called")

		familyMemberCoronaTestService.onMoveTestToBin = {
			XCTAssertEqual($0, testToRemove)
			moveTestToBinExpectation.fulfill()
		}

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		viewModel.didTapCoronaTestCellButton(at: IndexPath(row: 1, section: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue))

		waitForExpectations(timeout: .medium)
	}

	func testRemoveEntry() throws {
		let testToRemove: FamilyMemberCoronaTest = .antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "3"))

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 0), qrCodeHash: "0")),
			.pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "1")),
			testToRemove
		]

		let moveTestToBinExpectation = expectation(description: "moveTestToBin called")

		familyMemberCoronaTestService.onMoveTestToBin = {
			XCTAssertEqual($0, testToRemove)
			moveTestToBinExpectation.fulfill()
		}

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		viewModel.removeEntry(at: IndexPath(row: 0, section: FamilyMemberCoronaTestsViewModel.Section.coronaTests.rawValue))

		waitForExpectations(timeout: .medium)
	}

	func testRemoveAll() throws {
		let testToRemove: FamilyMemberCoronaTest = .antigen(.mock(displayName: "zxcv", sampleCollectionDate: Date(timeIntervalSinceNow: 3), qrCodeHash: "3"))

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [
			.pcr(.mock(displayName: "asdf", registrationDate: Date(timeIntervalSinceNow: 0), qrCodeHash: "0")),
			.pcr(.mock(displayName: "qwer", registrationDate: Date(timeIntervalSinceNow: 1), qrCodeHash: "1")),
			testToRemove
		]

		let moveTestToBinExpectation = expectation(description: "moveAllTestsToBin called")

		familyMemberCoronaTestService.onMoveAllTestsToBin = {
			moveTestToBinExpectation.fulfill()
		}

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		viewModel.removeAll()

		waitForExpectations(timeout: .medium)
	}

	func testMarkAllAsSeen() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()

		let evaluateShowingAllTestsExpectation = expectation(description: "evaluateShowingAllTests called")

		familyMemberCoronaTestService.onEvaluateShowingAllTests = {
			evaluateShowingAllTestsExpectation.fulfill()
		}

		let viewModel = FamilyMemberCoronaTestsViewModel(
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onCoronaTestCellTap: { _ in },
			onLastDeletion: { }
		)

		viewModel.markAllAsSeen()

		waitForExpectations(timeout: .medium)
	}

	func testUpdateTestResultsWithSuccessAndErrorNotPropagated() throws {
		let results: [Result<Void, CoronaTestServiceError>] = [.noCoronaTestOfRequestedType, .noRegistrationToken, .testExpired, .responseFailure(.fakeResponse), .responseFailure(.noResponse)].map { .failure($0) } + [.success(())]

		for result in results {
			let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()

			let updateTestResultsExpectation = expectation(description: "updateTestResults called")

			familyMemberCoronaTestService.updateTestResultsResult = result
			familyMemberCoronaTestService.onUpdateTestResults = { presentNotification in
				XCTAssertFalse(presentNotification)
				updateTestResultsExpectation.fulfill()
			}

			let viewModel = FamilyMemberCoronaTestsViewModel(
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				appConfigurationProvider: CachedAppConfigurationMock(),
				onCoronaTestCellTap: { _ in },
				onLastDeletion: { }
			)

			let isUpdatingTestResultsExpectation = expectation(description: "isUpdatingTestResults published")
			isUpdatingTestResultsExpectation.expectedFulfillmentCount = 3

			var receivedIsUpdatingTestResultsValues = [Bool]()
			let subscription = viewModel.isUpdatingTestResults
				.sink {
					receivedIsUpdatingTestResultsValues.append($0)
					isUpdatingTestResultsExpectation.fulfill()
				}

			viewModel.updateTestResults()

			waitForExpectations(timeout: .medium)

			XCTAssertNil(viewModel.testResultLoadingError.value)
			XCTAssertEqual(receivedIsUpdatingTestResultsValues, [false, true, false])

			subscription.cancel()
		}
	}

	func testUpdateTestResultsWithPropagatedErrors() throws {
		let errors: [CoronaTestServiceError] = [.teleTanError(.invalidResponse), .registrationTokenError(.invalidResponse), .malformedDateOfBirthKey, .testResultError(.invalidResponse), .responseFailure(.invalidResponse), .responseFailure(.invalidRequest), .responseFailure(.noNetworkConnection)]

		for error in errors {
			let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()

			let updateTestResultsExpectation = expectation(description: "updateTestResults called")

			familyMemberCoronaTestService.updateTestResultsResult = .failure(error)
			familyMemberCoronaTestService.onUpdateTestResults = { presentNotification in
				XCTAssertFalse(presentNotification)
				updateTestResultsExpectation.fulfill()
			}

			let viewModel = FamilyMemberCoronaTestsViewModel(
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				appConfigurationProvider: CachedAppConfigurationMock(),
				onCoronaTestCellTap: { _ in },
				onLastDeletion: { }
			)

			let isUpdatingTestResultsExpectation = expectation(description: "isUpdatingTestResults published")
			isUpdatingTestResultsExpectation.expectedFulfillmentCount = 3

			var receivedIsUpdatingTestResultsValues = [Bool]()
			let subscription = viewModel.isUpdatingTestResults
				.sink {
					receivedIsUpdatingTestResultsValues.append($0)
					isUpdatingTestResultsExpectation.fulfill()
				}

			viewModel.updateTestResults()

			waitForExpectations(timeout: .medium)

			XCTAssertEqual(viewModel.testResultLoadingError.value, error)
			XCTAssertEqual(receivedIsUpdatingTestResultsValues, [false, true, false])

			subscription.cancel()
		}
	}

}
