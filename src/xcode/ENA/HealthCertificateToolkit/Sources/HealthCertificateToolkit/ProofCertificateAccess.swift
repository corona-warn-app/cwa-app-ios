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

    public func fetchProofCertificate(for healthCertificates: [Base45], completion: @escaping (Result<CBORData, ProofCertificateFetchingError>) -> Void) {

        let url = URL(string: "https://api.certify.demo.ubirch.com/api/certify/v2/reissue/cbor")
        guard let requestUrl = url else {
            fatalError()
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        let healthCertificateAccess = HealthCertificateAccess()

        guard case let .success(healthCertificateCBORData) = healthCertificateAccess.extractCBOR(from: healthCertificates[0]) else {
            fatalError()
        }

        request.httpBody = healthCertificateCBORData

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error \(error)")
                    return
                }

                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response:\n \(dataString)")
                }

            completion(.success(CBORData()))
        }
        task.resume()
    }

    // MARK: - Internal

    let certificateAccess = CertificateAccess()
}
