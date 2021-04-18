////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ENAExposureSubmissionServiceTests: XCTestCase {
	
	func test_When_SubmissionWasSuccessful_Then_CheckinSubmittedIsTrue() {
		let keysRetrievalMock = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil) )
		let mockStore = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: mockStore)
		let eventStore = MockEventStore()
		
		mockStore.isSubmissionConsentGiven = true
		mockStore.submissionKeys = [SAP_External_Exposurenotification_TemporaryExposureKey()]
		mockStore.registrationToken = ""
		mockStore.positiveTestResultWasShown = true
		eventStore.createCheckin(Checkin.mock())
		
		mockStore.submissionCheckins = [eventStore.checkinsPublisher.value[0]]
		
		let checkinSubmissionService = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keysRetrievalMock,
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: mockStore,
			eventStore: eventStore,
			warnOthersReminder: warnOthersReminder
		)
		
		let completionExpectation = expectation(description: "Completion should be called.")
		checkinSubmissionService.submitExposure { error in
			
			XCTAssertNil(error)
			XCTAssertTrue(eventStore.checkinsPublisher.value[0].checkinSubmitted)
			
			completionExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
}
