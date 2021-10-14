//
// 🦠 Corona-Warn-App
//

struct HealthCertificateRestorationHandler: CertificateRestorationHandling {

	init(service: HealthCertificateService) {
		self.restore = { healthCertificate in
			service.addHealthCertificate(healthCertificate)
		}
	}

	var canRestore: ((HealthCertificate) -> Result<Void, CertificateRestorationError>) = { _ in
		return .success(())
	}

	var restore: ((HealthCertificate) -> Void)
}
