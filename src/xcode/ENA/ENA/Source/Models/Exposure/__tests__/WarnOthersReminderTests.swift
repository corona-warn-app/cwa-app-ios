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

@testable import ENA
import ExposureNotification
import XCTest

class WarnOthersReminderTests: XCTestCase {
	
	override func tearDown() {
		let store = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		// To ensure we have no scheduled warn others notifications leftovers
		warnOthersReminder.reset()
	}
	
	func testWarnOthers_allVariablesAreInitial() throws {
		
		let store = MockTestStore()
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		let timerOneTime = WarnOthersNotificationsTimeInterval.intervalOne
		XCTAssertEqual(warnOthersReminder.notificationOneTimeInterval, timerOneTime, "Notification timeInterval one has not the intial value of \(timerOneTime)")
		
		let timerTwoTime = WarnOthersNotificationsTimeInterval.intervalTwo
		XCTAssertEqual(Double(warnOthersReminder.notificationTwoTimeInterval), timerTwoTime, "Notification timeInterval two has not the intial value of \(timerTwoTime)")
		
		XCTAssertFalse(warnOthersReminder.positiveTestResultWasShown, "Inital value of hasPositiveTestResult should be 'false'")
		
	}
	
	func testWarnOthers_changedValuesShouldBeCorrect() throws {
		let store = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		warnOthersReminder.evaluateShowingTestResult(.positive)
		XCTAssertTrue(warnOthersReminder.positiveTestResultWasShown, "Inital value of hasPositiveTestResult should be 'true'")
		
		warnOthersReminder.notificationOneTimeInterval = TimeInterval(42)
		XCTAssertEqual(warnOthersReminder.notificationOneTimeInterval, TimeInterval(42), "Notification timeInterval one has not the intial value of '42'")
		
		warnOthersReminder.notificationTwoTimeInterval = TimeInterval(43)
		XCTAssertEqual(warnOthersReminder.notificationTwoTimeInterval, TimeInterval(43), "Notification timeInterval two has not the intial value of '43'")
		
		warnOthersReminder.reset()
		XCTAssertFalse(warnOthersReminder.positiveTestResultWasShown, "Inital value of hasPositiveTestResult should be 'false'")
	}
	
	
	func testWarnOthers_SubmissionConsentGiven() throws {
		
		let store = MockTestStore()
		store.isSubmissionConsentGiven = true
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		XCTAssertTrue(warnOthersReminder.isSubmissionConsentGiven, "Submission consent given should be true")
		
	}
	
	func testWarnOthers_noSubmissionConsentGiven() throws {
		
		let store = MockTestStore()
		store.isSubmissionConsentGiven = false
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		XCTAssertFalse(warnOthersReminder.isSubmissionConsentGiven, "Submission consent given should be false")
		
	}
	
}
