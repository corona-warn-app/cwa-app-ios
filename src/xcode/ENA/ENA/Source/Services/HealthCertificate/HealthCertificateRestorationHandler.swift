//
// 🦠 Corona-Warn-App
//

struct HealthCertificateRestorationHandler: CertificateRestorationHandling {

	init(service: HealthCertificateService) {
		self.restore = { healthCertificate in
			service.addHealthCertificate(healthCertificate)
		}
	}

	var restore: ((HealthCertificate) -> Void)
}
