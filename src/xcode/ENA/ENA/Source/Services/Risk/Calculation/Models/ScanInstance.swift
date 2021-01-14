//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

struct ScanInstance: Codable {

	// MARK: - Init

	init(from scanInstance: ENScanInstance) {
		minAttenuation = scanInstance.minimumAttenuation
		typicalAttenuation = scanInstance.typicalAttenuation
		secondsSinceLastScan = scanInstance.secondsSinceLastScan
	}

	// MARK: - Internal

	let minAttenuation: ENAttenuation
	let typicalAttenuation: ENAttenuation
	let secondsSinceLastScan: Int

}
