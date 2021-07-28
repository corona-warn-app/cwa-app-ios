////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol HealthCertificateNotificationProviding {
	func appStartCheck()
	func creation()
	func deletion()
	func appConfigUpdate()
}
