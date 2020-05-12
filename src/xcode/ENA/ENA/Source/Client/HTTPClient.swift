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

        static let mock = Configuration(baseURL: "http://distribution-mock-cwa-server.apps.p006.otc.mcs-paas.io", apiVersion: "v1", country: "DE")
    }

    init(configuration: Configuration = .mock, session: Session = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: Properties
    private let configuration: Configuration
    private let session: Session

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

    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {
        // swiftlint:disable:next force_unwrapping
        _ = URL(string: "\(configuration.baseURL)/version/\(configuration.apiVersion)/diagnosis-keys/country/\(configuration.country)/date/")!

    }
}

// MARK: Extensions

extension Session {
    func pausedDataTask(
        with url: URL,
        handler: @escaping (Result<Data, Error>) -> Void
    ) -> SessionTask {
        sessionTask(with: url) { data, _, error in
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
