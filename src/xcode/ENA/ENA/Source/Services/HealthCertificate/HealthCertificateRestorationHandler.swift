//
// 🦠 Corona-Warn-App
//

struct HealthCertificateRestorationHandler: CertificateRestorationHandling {

	init(service: HealthCertificateService) {
		self.service = service

		self.restore  = { certificate in
			let healthCertifiedPerson = service.healthCertifiedPerson(for: certificate)
			service.addHealthCertificate(certificate, to: healthCertifiedPerson)
		}
	}

	var canRestore: ((HealthCertificate) -> Result<Void, CertificateRestorationError>) = { _ in
		return .success(())
	}

	var restore: ((HealthCertificate) -> Void)

	private let service: HealthCertificateService
}
