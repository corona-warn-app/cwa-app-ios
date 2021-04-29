////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct ProofCertificate: Codable {

	// MARK: - Internal

	let cborRepresentation: Data
	let expirationDate: Date

}
