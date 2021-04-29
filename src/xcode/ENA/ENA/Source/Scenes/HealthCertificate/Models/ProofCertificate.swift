////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct ProofCertificate: Codable, Equatable {

	// MARK: - Internal

	let cborRepresentation: Data
	let expirationDate: Date

}
