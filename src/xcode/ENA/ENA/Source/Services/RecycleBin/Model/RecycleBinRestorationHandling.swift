//
// 🦠 Corona-Warn-App
//

enum RestorationError: Error {
	case testError(TestRestorationError)
}

enum TestRestorationError: Error {
	case testTypeAlreadyRegistered
}

protocol UserTestRestorationHandling {
	var canRestore: ((UserCoronaTest) -> Result<Void, TestRestorationError>) { get }
	var restore: ((UserCoronaTest) -> Void) { get }
}

protocol CertificateRestorationHandling {
	var restore: ((HealthCertificate) -> Void) { get }
}

struct UserTestRestorationHandlerFake: UserTestRestorationHandling {
	var canRestore: ((UserCoronaTest) -> Result<Void, TestRestorationError>) = { _ in return .success(()) }
	var restore: ((UserCoronaTest) -> Void) = { _ in }
}

struct CertificateRestorationHandlerFake: CertificateRestorationHandling {
	var restore: ((HealthCertificate) -> Void) = { _ in }
}
