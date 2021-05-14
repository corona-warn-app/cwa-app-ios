//
// 🦠 Corona-Warn-App
//

import Foundation

public protocol ProofCertificateDownloadProtocol {
    func fetchProofCertificate(
        for healthCertificates: [Base45],
        with httpService: HTTPServiceProtocol,
        completion: @escaping (Result<Base45?, ProofCertificateFetchingError>) -> Void
    )
}

public struct ProofCertificateDownload: ProofCertificateDownloadProtocol {

    // MARK: - Init

    public init() {}

    // MARK: - Public

    public func fetchProofCertificate(
        for healthCertificates: [Base45],
        with httpService: HTTPServiceProtocol = HTTPService(),
        completion: @escaping (Result<Base45?, ProofCertificateFetchingError>) -> Void
    ) {
        let certificateAccess = DigitalGreenCertificateAccess()

        let eligibleCertificates =
            healthCertificates
            .compactMap { (base45) -> CBORData? in
                let result = certificateAccess.extractCBOR(from: base45)
                switch result {
                case .success(let healthCertificateCBORData):
                    return healthCertificateCBORData
                case .failure:
                    return nil
                }
            }
            .filter {
                switch certificateAccess.extractCertificate(from: $0) {
                case .success(let certificate):
                    return certificate.vaccinationCertificates[0].isEligibleForProofCertificate
                case .failure:
                    return false
                }
            }

        guard !eligibleCertificates.isEmpty else {
            completion(.success(nil))
            return
        }

        // This call recursively posts the eligible health certificates one after the other.
        // The operation completes, as soon as the first proof certificate is returned from the backend.
        fetchProofCertificateRecursion(for: eligibleCertificates, with: httpService, completion: completion)
    }

    // MARK: - Private

    private func fetchProofCertificateRecursion(
        for healthCertificates: [CBORData],
        with httpService: HTTPServiceProtocol = HTTPService(),
        completion: @escaping (Result<Base45?, ProofCertificateFetchingError>) -> Void
    ) {

        let url = URL(string: "https://www.test.de")
        guard let requestUrl = url else {
            fatalError()
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/cbor", forHTTPHeaderField: "Content-Type")
        request.addValue("application/cbor+base45", forHTTPHeaderField: "Accept")

        guard let healthCertificate = healthCertificates.first else {
            // Exit of recursion.
            // At this point all health certificates where send to the server and not one proof certificate was returned. In this case the fetch counts as success without a proof certificate (nil).
            completion(.success(nil))
            return
        }

        request.httpBody = healthCertificate

        httpService.execute(request: request) { (data, response, error) in
            // If there is an error or response is nil, it indicates a transport problem and PC_NETWORK_ERROR is returned.
            guard error == nil,
                  let response = response as? HTTPURLResponse else {
                completion(.failure(.PC_NETWORK_ERROR))
                return
            }

            // Remove the first certificate and pass the rest into the recursion.
            var _healthCertificates = healthCertificates
            _healthCertificates.removeFirst()

            switch response.statusCode {
            case 200:
                if let data = data {
                    // Exit of recursion.
                    // We exit the recursion if the server returns the first proof certificate. Ignoring the rest of the health certificates.
                    let base45 = Base45(data: data, encoding: .utf8)
                    completion(.success(base45))
                } else {
                    // If there is no data returned, we try our luck with the next health certificate.
                    fetchProofCertificateRecursion(for: _healthCertificates, with: httpService, completion: completion)
                }
            // If status code indicates an internal server error, PC_SERVER_ERROR is returned.
            case 500...599:
                completion(.failure(.PC_SERVER_ERROR))
            // All other status codes are indicating, that no proof certificate can be obtained. In this case, we try our luck with the next health certificate.
            default:
                fetchProofCertificateRecursion(for: _healthCertificates, with: httpService, completion: completion)
            }
        }
    }
}
