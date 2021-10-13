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

struct TestRestorationHandlerFake: TestRestorationHandling {
	var canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>) = { _ in return .success(()) }
	var restore: ((CoronaTest) -> Void) = { _ in }
}

struct CertificateRestorationHandlerFake: CertificateRestorationHandling {
	var canRestore: ((HealthCertificate) -> Result<Void, CertificateRestorationError>) = { _ in return .success(()) }
	var restore: ((HealthCertificate) -> Void) = { _ in }
}
