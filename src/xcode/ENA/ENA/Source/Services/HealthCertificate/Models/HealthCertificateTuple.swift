//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

public struct HealthCertificateTuple {
	
	// MARK: - Init

	init(certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson) {
		self.certificate = certificate
		self.certifiedPerson = certifiedPerson
	}
	
	// MARK: - Public

	public let certificate: HealthCertificate
	public let certifiedPerson: HealthCertifiedPerson
}
