//
// 🦠 Corona-Warn-App
//

enum RestorationError: Error {
	case testError(TestRestorationError)
}

enum TestRestorationError: Error {
	case testTypeAlreadyRegistered
}

protocol TestRestorationHandling {
	var canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>) { get }
	var restore: ((CoronaTest) -> Void) { get }
}

protocol CertificateRestorationHandling {
	var restore: ((HealthCertificate) -> Void) { get }
}

struct TestRestorationHandlerFake: TestRestorationHandling {
	var canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>) = { _ in return .success(()) }
	var restore: ((CoronaTest) -> Void) = { _ in }
}

struct CertificateRestorationHandlerFake: CertificateRestorationHandling {
	var restore: ((HealthCertificate) -> Void) = { _ in }
}
