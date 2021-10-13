//
// 🦠 Corona-Warn-App
//

enum RestorationError: Error {
	case testError(TestRestorationError)
	case certificateError(CertificateRestorationError)
}

enum TestRestorationError: Error {
	case some
}

enum CertificateRestorationError: Error {
	case some
}

protocol TestRestorationHandling {
	var canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>) { get set }
	var restore: ((CoronaTest) -> Void) { get set }
}

protocol CertificateRestorationHandling {
	var canRestore: ((HealthCertificate) -> Result<Void, CertificateRestorationError>) { get set }
	var restore: ((HealthCertificate) -> Void) { get set }
}
