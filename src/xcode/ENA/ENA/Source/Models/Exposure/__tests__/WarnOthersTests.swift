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

class WarnOthersTests: XCTestCase {
	
	private var store: SecureStore!

    override func setUpWithError() throws {
		store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456", serverEnvironment: ServerEnvironment())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWarnOthers_allVariablesAreInitial() throws {
		
		let warnOthers = WarnOthers(store: store)
		
		let timerOneTime = TimeInterval(WarnOthersNotificationsTimer.timerOneTime.rawValue)
		XCTAssertEqual(warnOthers.notificationOneTimer, timerOneTime, "Notification timer one has not the intial value of \(timerOneTime)")
		
		let timerTwoTime = TimeInterval(WarnOthersNotificationsTimer.timerTwoTime.rawValue)
		XCTAssertEqual(Double(warnOthers.notificationTwoTimer), timerTwoTime, "Notification timer two has not the intial value of \(timerTwoTime)")
		
		XCTAssertFalse(warnOthers.hasStoredResult, "Inital value of storedResult should be 'false'")
		
		warnOthers.evaluateNotificationState(testResult: .positive)
		XCTAssertTrue(warnOthers.hasStoredResult, "Inital value of storedResult should be 'true'")
		
		warnOthers.notificationOneTimer = 42
		XCTAssertEqual(warnOthers.notificationOneTimer, 42, "Notification timer one has not the intial value of '42'")
		
		warnOthers.notificationTwoTimer = 42
		XCTAssertEqual(warnOthers.notificationTwoTimer, 42, "Notification timer two has not the intial value of '42'")
		
		warnOthers.reset()
		XCTAssertFalse(warnOthers.hasStoredResult, "Inital value of storedResult should be 'false'")
		
    }


}
