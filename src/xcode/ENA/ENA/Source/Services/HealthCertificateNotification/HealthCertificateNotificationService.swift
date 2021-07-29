////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

protocol HealthCertificateNotificationProviding {
	func scheduleNotificationAfterCreation(id: String)
	func scheduleNotificationAfterDeletion(id: String)
}

final class HealthCertificateNotificationService: HealthCertificateNotificationProviding {

	// MARK: - Init

	init(
		existingCertificates: [HealthCertifiedPerson],
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		appConfigurationProvider: AppConfigurationProviding
	) {
		self.existingCertificates = existingCertificates
		self.notificationCenter = notificationCenter
		self.appConfigurationProvider = appConfigurationProvider
		// trigger init check
		
		// register publisher for app config change
		
	}
	
	// MARK: - Protocol HealthCertificateNotificationProviding
	
	func scheduleNotificationAfterCreation(id: String) {
		
	}
	
	func scheduleNotificationAfterDeletion(id: String) {
		
	}
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let existingCertificates: [HealthCertifiedPerson]
	private let notificationCenter: UserNotificationCenter
	private let appConfigurationProvider: AppConfigurationProviding
}
