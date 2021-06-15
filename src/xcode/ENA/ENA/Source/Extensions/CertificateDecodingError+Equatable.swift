////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension CertificateDecodingError: Equatable {
	
	// MARK: - Protocol Equatable

	public static func == (lhs: CertificateDecodingError, rhs: CertificateDecodingError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
