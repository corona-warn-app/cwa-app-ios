//
// 🦠 Corona-Warn-App
//

import UIKit

protocol WarnOthersRemindable {
	
	var positiveTestResultWasShown: Bool { get }
	
	var isSubmissionConsentGiven: Bool { get }

	var notificationOneTimeInterval: TimeInterval { get set }
	var notificationTwoTimeInterval: TimeInterval { get set }
	
	func evaluateShowingTestResult(_ testResult: TestResult)
	func reset()
	func cancelNotifications()

}
