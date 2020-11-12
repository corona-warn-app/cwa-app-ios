//
// 🦠 Corona-Warn-App
//

import Foundation

extension SceneDelegate {
	struct State {
		var exposureManager: ExposureManagerState
		var detectionMode: DetectionMode
		var risk: Risk?
		var riskDetectionFailed: Bool
	}
}
