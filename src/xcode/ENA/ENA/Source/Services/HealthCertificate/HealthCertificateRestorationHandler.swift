//
// 🦠 Corona-Warn-App
//

struct HealthCertificateRestorationHandler: CertificateRestorationHandling {

	// MARK: - Init

	init(service: HealthCertificateService) {
		restore = { healthCertificate in
			service.addHealthCertificate(
				healthCertificate,
				completedNotificationRegistration: { })
		}
	}

	// MARK: - Protocol CertificateRestorationHandling

	let restore: ((HealthCertificate) -> Void)

}
