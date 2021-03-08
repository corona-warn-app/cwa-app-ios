////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation

final class StateCellViewModel {

	init() {
		self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
	}

	let authorizationStatus: AVAuthorizationStatus
}
