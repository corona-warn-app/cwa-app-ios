////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol HealthCertificateNotificationProviding {
	func scheduleNotificationsAfterCreation()
	func scheduleNotificationsAfterDeletion()
}

final class HealthCertificateNotificationService: HealthCertificateNotificationProviding {

	// MARK: - Init

	init() {
		
		// trigger init check
		
		// register publisher for app config change
		
	}
	
	// MARK: - Protocol HealthCertificateNotificationProviding
	
	func scheduleNotificationsAfterCreation() {
		
	}
	
	func scheduleNotificationsAfterDeletion() {
		
	}
	
	// MARK: - Internal
	
	// MARK: - Private
}

