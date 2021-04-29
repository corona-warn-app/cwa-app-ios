////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct HealthCertificateRepresentations: Codable, Equatable {

	// MARK: - Internal

	let base45: String
	let cbor: Data
	let json: Data

}
