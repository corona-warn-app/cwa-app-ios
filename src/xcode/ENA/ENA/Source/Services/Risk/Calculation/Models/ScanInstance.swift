//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

struct ScanInstance: Codable, Equatable {

	// MARK: - Init

	init(from scanInstance: ENScanInstance) {
		minAttenuation = scanInstance.minimumAttenuation
		typicalAttenuation = scanInstance.typicalAttenuation
		secondsSinceLastScan = scanInstance.secondsSinceLastScan
	}

	// MARK: - Protocol Equatable

	static func == (lhs: ScanInstance, rhs: ScanInstance) -> Bool {
		return  lhs.minAttenuation == rhs.minAttenuation &&
			lhs.typicalAttenuation == rhs.typicalAttenuation &&
			lhs.secondsSinceLastScan == rhs.secondsSinceLastScan
	}

	// MARK: - Internal

	let minAttenuation: ENAttenuation
	let typicalAttenuation: ENAttenuation
	let secondsSinceLastScan: Int

}
