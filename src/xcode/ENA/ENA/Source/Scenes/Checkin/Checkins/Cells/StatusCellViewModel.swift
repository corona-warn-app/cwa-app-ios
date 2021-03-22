////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import AVFoundation

final class StatusCellViewModel {

	init() {
		self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
	}

	let authorizationStatus: AVAuthorizationStatus

	var tableViewCell: UITableViewCell.Type {
		switch authorizationStatus {
		case .restricted, .denied:
			return MissingPermissionsTableViewCell.self
		case .authorized, .notDetermined:
			return ScanQRCodeTableViewCell.self

		@unknown default:
			Log.debug("Unknown new case discovered", log: .checkin)
			return MissingPermissionsTableViewCell.self
		}
	}

}
