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

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {

        let urlString = "\(config.serverUrl)/version/\(config.apiVersion)/parameters/country/\(config.country)"
        log(message: "Fetching exposureConfiguation from: \(urlString)")


        // swiftlint:disable:next force_unwrapping
        let url = URL(string: urlString)!
        let task = session.dataTask(with: url) { result in
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

    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {
        // swiftlint:disable:next force_unwrapping
        _ = URL(string: "\(config.serverUrl)/version/\(config.apiVersion)/diagnosis-keys/country/\(config.country)/date/")!

    }
}

// MARK: Extensions

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

fileprivate extension ENExposureConfiguration {
    convenience init(from data: Data) throws {
        self.init()

        let signedPayload = try SignedPayload(serializedData: data)
        let riskscoreParameters = try RiskScoreParameters(serializedData: signedPayload.payload)

        self.minimumRiskScore = 0  // TODO: Update once the backend provides this value

        self.attenuationWeight = riskscoreParameters.attenuationWeight
        self.attenuationLevelValues = riskscoreParameters.attenuation.asArray
        self.daysSinceLastExposureLevelValues = riskscoreParameters.daysSinceLastExposure.asArray
        self.daysSinceLastExposureWeight = riskscoreParameters.daysWeight
        self.durationLevelValues = riskscoreParameters.duration.asArray
        self.durationWeight = riskscoreParameters.durationWeight
        self.transmissionRiskLevelValues = riskscoreParameters.transmission.asArray
        self.transmissionRiskWeight = riskscoreParameters.transmissionWeight
    }
}

fileprivate extension RiskLevel {
    var asNumber: NSNumber {
        NSNumber(value: rawValue)
    }
}

fileprivate extension RiskScoreParameters.TransmissionRiskParameters {
    var asArray: [NSNumber] {
        [appDefined1, appDefined2, appDefined3, appDefined4, appDefined5, appDefined6, appDefined7, appDefined8].map { $0.asNumber }
    }
}

fileprivate extension RiskScoreParameters.DaysSinceLastExposureRiskParameters {
    var asArray: [NSNumber] {
        [ge14Days, ge12Lt14Days, ge10Lt12Days, ge8Lt10Days, ge6Lt8Days, ge4Lt6Days, ge2Lt4Days, ge0Lt2Days].map { $0.asNumber }
    }
}

fileprivate extension RiskScoreParameters.DurationRiskParameters {
    var asArray: [NSNumber] {
        [eq0Min, gt0Le5Min, gt5Le10Min, gt10Le15Min, gt15Le20Min, gt20Le25Min, gt25Le30Min, gt30Min].map { $0.asNumber }
    }
}

fileprivate extension RiskScoreParameters.AttenuationRiskParameters {
    var asArray: [NSNumber] {
        [gt73Dbm, gt63Le73Dbm, gt51Le63Dbm, gt33Le51Dbm, gt27Le33Dbm, gt15Le27Dbm, gt10Le15Dbm, lt10Dbm].map { $0.asNumber }
    }
}
