//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

public struct HealthCertificateTuple {
	
	init(certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson) {
		self.certificate = certificate
		self.certifiedPerson = certifiedPerson
	}

	public let certificate: HealthCertificate
	public let certifiedPerson: HealthCertifiedPerson
}
