//
//  HTTPClient.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation
import ExposureNotification

class HTTPClient: Client {

    init(config: BackendConfig, session: URLSession = URLSession.shared) {
        self.config = config
        self.session = session
    }

    // MARK: Properties
    private let config: BackendConfig
    private let session: URLSession
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy-mm-dd"
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    let submissionEndpoint = "diagnosis-keys"

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
        
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
        let serverKeys = keys.compactMap { diagnosisKey in
            Sap_Key.with {
                $0.keyData = diagnosisKey.keyData
                $0.rollingStartNumber = diagnosisKey.rollingStartNumber
                $0.rollingPeriod = diagnosisKey.rollingPeriod
                $0.transmissionRiskLevel = Int32(diagnosisKey.transmissionRiskLevel)
            }
        }

        let submissionPayload = SubmissionPayload.with {
            $0.keys = serverKeys
        }

        guard let submissionPayloadData = try? submissionPayload.serializedData() else {
            // How's this possible Apple?
            logError(message: "Couldn't serialize submission payload.")
            fatalError()
        }

        let request = createSubmissionRequest(tan: tan, keys: submissionPayloadData)

        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else {
                completion(.generalError)
                return
            }

            if let error = error {
                // TODO: Check network connection before the request
                logError(message: "An error occurred while submitting keys to the server: \(error.localizedDescription)")
                completion(.networkError)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                // This should never happen, but just in case.
                logError(message: "Response returned is not an HTTP response.")
                completion(.generalError)
                return
            }

            if response.statusCode != 200 {
                self.handleSubmissionErrorResponse(responseCode: response.statusCode, completion: completion)
                return
            }

            log(message: "Keys successfully submitted to the server.")
            completion(nil)
        }

        log(message: "Starting keys submission to the server...")
        dataTask.resume()
    }

    private func createSubmissionRequest(tan: String, keys: Data) -> URLRequest {
        let url = URL(string: "http://submission-cwa-server.apps.p006.otc.mcs-paas.io/version/\(config.apiVersion)/\(submissionEndpoint)")
        var request = URLRequest(url: url!)

        request.setValue(tan, forHTTPHeaderField: "cwa-authorization")
        request.setValue(String(0), forHTTPHeaderField: "cwa-fake")
        request.setValue(config.apiVersion, forHTTPHeaderField: "version")
        request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = keys

        return request
    }

    private func handleSubmissionErrorResponse(responseCode: Int, completion: @escaping SubmitKeysCompletionHandler) {
        switch responseCode {
        case 403:
            completion(.invalidTan)
        case 400:
            completion(.invalidPayloadOrHeaders)
        default:
            completion(.generalError)
        }
    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {

    }
}

extension URLSession {
    func dataTask(
        with url: URL,
        handler: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: url) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(data ?? Data()))
            }
        }
    }
}
