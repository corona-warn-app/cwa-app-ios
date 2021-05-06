//
// 🦠 Corona-Warn-App
//

import Foundation

public typealias CBORData = Data

public struct ProofCertificateAccess {

    // MARK: - Public

    public func extractCBORWebTokenHeader(from cborData: CBORData) -> Result<CBORWebTokenHeader, CertificateDecodingError> {
        return certificateAccess.extractHeader(from: cborData)
    }

    public func extractDigitalGreenCertificate(from cborData: CBORData) -> Result<DigitalGreenCertificate, CertificateDecodingError> {
        return certificateAccess.extractDigitalGreenCertificate(from: cborData)
    }

    public func fetchProofCertificate(for healthCertificates: [Base45], completion: @escaping (Result<CBORData?, ProofCertificateFetchingError>) -> Void) {

        let healthCertificateAccess = HealthCertificateAccess()
        let proofCertificateAccess = ProofCertificateAccess()

        let eligibleCertificates =
            healthCertificates.compactMap { (base45) -> CBORData? in
                switch healthCertificateAccess.extractCBOR(from: base45) {
                case .success(let healthCertificateCBORData):
                    return healthCertificateCBORData
                case .failure:
                    return nil
                }
            }.filter {
                switch proofCertificateAccess.extractDigitalGreenCertificate(from: $0) {
                case .success(let certificate):
                    return certificate.vaccinationCertificates[0].isEligibleForProofCertificate
                case .failure:
                    return false
                }
            }

        guard !eligibleCertificates.isEmpty else {
            // ToDo: At the moment this point is tbd in the spec.
            completion(.success(nil))
            return
        }

        // Fetch the proof certificate in sequence.
        // The operation is completed, as soon as the first proof certificate is returned from the backend.
        fetchProofCertificateRecursion(for: eligibleCertificates, completion: completion)
    }

    // MARK: - Internal

    let certificateAccess = CertificateAccess()

    // MARK: - Private

    private func fetchProofCertificateRecursion(for healthCertificates: [CBORData], completion: @escaping (Result<CBORData?, ProofCertificateFetchingError>) -> Void) {

        let url = URL(string: "https://api.certify.demo.ubirch.com/api/certify/v2/reissue/cbor")
        guard let requestUrl = url else {
            fatalError()
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        guard let healthCertificate = healthCertificates.last else {
            completion(.success(nil))
            return
        }

        request.httpBody = healthCertificate

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.PC_NETWORK_ERROR))
                return
            }

            switch response.statusCode {
            case 500...599:
                completion(.failure(.PC_SERVER_ERROR))
            default:
                fetchProofCertificateRecursion(for: healthCertificates.dropLast(), completion: completion)
            }

            if let data = data {
                completion(.success(data))
            } else {
                fetchProofCertificateRecursion(for: healthCertificates.dropLast(), completion: completion)
            }
        }
        task.resume()
    }
}
