//
//  HTTPClient.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation
import ExposureNotification

final class HTTPClient: Client {
    struct Configuration {
        // MARK: Properties
        let baseURL: String
        let apiVersion: String
        let country: String
        var submissionServiceUrl: String { return "http://submission-cwa-server.apps.p006.otc.mcs-paas.io/version/\(apiVersion)/diagnosis-keys" }

        static let mock = Configuration(baseURL: "http://distribution-mock-cwa-server.apps.p006.otc.mcs-paas.io", apiVersion: "v1", country: "DE")

    }

    init(configuration: Configuration = .mock, session: URLSession = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: Properties
    private let configuration: Configuration
    private let session: URLSession

    // Will be needed to format available days when fetching diagnosis keys
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {

        let urlString = "\(configuration.baseURL)/version/\(configuration.apiVersion)/parameters/country/\(configuration.country)"
        log(message: "Fetching exposureConfiguation from: \(urlString)")


        // swiftlint:disable:next force_unwrapping
        let url = URL(string: urlString)!
        let task = session.pausedDataTask(with: url) { result in
            switch result {
            case .success(let data):
                do {
                    let exposureConfig = try ENExposureConfiguration(from: data)
                    log(message: "Retrieved exposureConfiguation from server")
                    completion(.success(exposureConfig))
                } catch {
                    logError(message: error.localizedDescription)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
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

        let submissionPayload = Sap_SubmissionPayload.with {
            $0.keys = serverKeys
        }

        guard let submissionPayloadData = try? submissionPayload.serializedData() else {
            // How's this possible Apple?
            logError(message: "Couldn't serialize submission payload.")
            fatalError()
        }

        let request = createSubmissionRequest(tan: tan, keys: submissionPayloadData)

        let dataTask = session.dataTask(with: request) { [weak self] _, response, error in
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
        let url = URL(string: configuration.submissionServiceUrl)
        var request = URLRequest(url: url!)

        request.setValue(tan, forHTTPHeaderField: "cwa-authorization")
        request.setValue(String(0), forHTTPHeaderField: "cwa-fake")
        request.setValue(configuration.apiVersion, forHTTPHeaderField: "version")
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
        // swiftlint:disable:next force_unwrapping
        _ = URL(string: "\(configuration.baseURL)/version/\(configuration.apiVersion)/diagnosis-keys/country/\(configuration.country)/date/")!

    }
}

// MARK: Extensions

extension URLSession {
    func pausedDataTask(
        with url: URL,
        handler: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        dataTask(with: url) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(data ?? Data()))
            }
        }
    }
}

fileprivate extension ENExposureConfiguration {
    convenience init(from data: Data) throws {
        self.init()

        let signedPayload = try Sap_SignedPayload(serializedData: data)
        let riskscoreParameters = try Sap_RiskScoreParameters(serializedData: signedPayload.payload)

        minimumRiskScore = 0

        attenuationWeight = riskscoreParameters.attenuationWeight
        attenuationLevelValues = riskscoreParameters.attenuation.asArray
        daysSinceLastExposureLevelValues = riskscoreParameters.daysSinceLastExposure.asArray
        daysSinceLastExposureWeight = riskscoreParameters.daysWeight
        durationLevelValues = riskscoreParameters.duration.asArray
        durationWeight = riskscoreParameters.durationWeight
        transmissionRiskLevelValues = riskscoreParameters.transmission.asArray
        transmissionRiskWeight = riskscoreParameters.transmissionWeight
    }
}

fileprivate extension Sap_RiskLevel {
    var asNumber: NSNumber {
        NSNumber(value: rawValue)
    }
}

fileprivate extension Sap_RiskScoreParameters.TransmissionRiskParameters {
    var asArray: [NSNumber] {
        [appDefined1, appDefined2, appDefined3, appDefined4, appDefined5, appDefined6, appDefined7, appDefined8].map { $0.asNumber }
    }
}

fileprivate extension Sap_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
    var asArray: [NSNumber] {
        [ge14Days, ge12Lt14Days, ge10Lt12Days, ge8Lt10Days, ge6Lt8Days, ge4Lt6Days, ge2Lt4Days, ge0Lt2Days].map { $0.asNumber }
    }
}

fileprivate extension Sap_RiskScoreParameters.DurationRiskParameters {
    var asArray: [NSNumber] {
        [eq0Min, gt0Le5Min, gt5Le10Min, gt10Le15Min, gt15Le20Min, gt20Le25Min, gt25Le30Min, gt30Min].map { $0.asNumber }
    }
}

fileprivate extension Sap_RiskScoreParameters.AttenuationRiskParameters {
    var asArray: [NSNumber] {
        [gt73Dbm, gt63Le73Dbm, gt51Le63Dbm, gt33Le51Dbm, gt27Le33Dbm, gt15Le27Dbm, gt10Le15Dbm, lt10Dbm].map { $0.asNumber }
    }
}
