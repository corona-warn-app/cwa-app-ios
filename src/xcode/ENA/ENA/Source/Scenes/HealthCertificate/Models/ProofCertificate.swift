////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct ProofCertificate: Codable {

	// MARK: - Internal

	let base45: String
	let cborRepresentation: Data
	let expirationDate: Date

}
