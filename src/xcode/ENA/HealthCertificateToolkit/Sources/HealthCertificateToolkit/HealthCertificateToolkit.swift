import Foundation

enum HealthCertificateFetchingError: Error {
    case something
    case general
}

enum HealthCertificateDecodingError: Error {
    case something
    case general
}

protocol HealthCertificateToolkitProtocol {
    func decode(base45: String) -> Result<HealthCertificateRepresentations, HealthCertificateDecodingError>
    func fetchProofCertificate(for healthCertificates: [Data], completion: (Result<Data, HealthCertificateFetchingError>) -> Void)
}

struct HealthCertificateToolkit: HealthCertificateToolkitProtocol {
    func decode(base45: String) -> Result<HealthCertificateRepresentations, HealthCertificateDecodingError> {
        .success( .fake())
    }

    func fetchProofCertificate(for healthCertificates: [Data], completion: (Result<Data, HealthCertificateFetchingError>) -> Void) {

    }
}

// MARK: - Fakes

struct ElectronicHealthCertificateFake: HealthCertificateToolkitProtocol {
    func decode(base45: String) -> Result<HealthCertificateRepresentations, HealthCertificateDecodingError> {
        .success(.fake())
    }

    func fetchProofCertificate(for healthCertificates: [Data], completion: (Result<Data, HealthCertificateFetchingError>) -> Void) {
        completion(.success(Data()))
    }
}
