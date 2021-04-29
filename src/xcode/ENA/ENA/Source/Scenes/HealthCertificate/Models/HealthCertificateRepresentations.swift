////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct HealthCertificateRepresentations: Codable {

	// MARK: - Internal

	let base45: String
	let cbor: Data
	let json: Data

}
