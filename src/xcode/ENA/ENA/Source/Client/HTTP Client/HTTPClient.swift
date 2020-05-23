//
//  HTTPClient.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation
import ExposureNotification
import ZIPFoundation

final class HTTPClient: Client {
   // MARK: Creating

   init(
        configuration: Configuration = .production,
        session: URLSession = .coronaWarnSession()
    ) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: Properties
    private let configuration: Configuration
    private let session: URLSession

    func exposureConfiguration(
        completion: @escaping ExposureConfigurationCompletionHandler
    ) {
        log(message: "Fetching exposureConfiguation from: \(configuration.configurationURL)")
        session.GET(configuration.configurationURL) { result in

            switch result {
            case .success(let response):
                guard let data = response.body else {
                    completion(nil)
                    return
                }
                guard response.hasAcceptableStatusCode else {
                    completion(nil)
                    return
                }

                guard let archive = Archive(data: data, accessMode: .read) else {
                    logError(message: "Failed to download configuration. Unable to create zip archive.")
                    completion(nil)
                    return
                }
                do {
                    let package = try archive.extractKeyPackage()
                    log(message: "Retrieved exposureConfiguation from server")
                    
                    completion(try ENExposureConfiguration(from: package.bin))
                } catch {
                    logError(message: "Failed to get exposure configuration: \(error.localizedDescription)")
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }

    func submit(
        keys: [ENTemporaryExposureKey],
        tan: String,
        completion: @escaping SubmitKeysCompletionHandler
    ) {
        guard let request = try? URLRequest.submitKeysRequest(
            configuration: configuration,
            tan: tan,
            keys: keys
            ) else {
                completion(.other(nil))
                return
        }

        session.response(for: request) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200: completion(nil)
                case 400: completion(.invalidPayloadOrHeaders)
                case 403: completion(.invalidTan)
                default: completion(.other(nil))
                }
            case .failure(let error):
                completion(.other(error))
            }
        }
    }

    func availableDays(
        completion completeWith: @escaping AvailableDaysCompletionHandler
    ) {
        let url = configuration.availableDaysURL

        session.GET(url) { result in
            switch result {
            case .success(let response):
                guard let data = response.body else {
                    completeWith(.failure(.invalidResponse))
                    return
                }
                guard response.hasAcceptableStatusCode else {
                    completeWith(.failure(.invalidResponse))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let days = try decoder
                        .decode(
                            [String].self,
                            from: data
                    )
                    completeWith(.success(days))
                } catch {
                    completeWith(.failure(.invalidResponse))
                    return
                }
            case .failure(let error):
                completeWith(.failure(error))
            }
        }
    }

    func availableHours(
        day: String,
        completion completeWith: @escaping AvailableHoursCompletionHandler
    ) {
        let url = configuration.availableHoursURL(day: day)

        session.GET(url) { result in
            switch result {
            case .success(let response):
                // We accept 404 responses since this can happen in case there
                // have not been any new cases reported on that day.
                // We don't report this as an error to simplify things for the consumer.
                guard response.statusCode != 404 else {
                    completeWith(.success([]))
                    return
                }

                guard let data = response.body else {
                    completeWith(.failure(.invalidResponse))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let hours = try decoder.decode([Int].self, from: data)
                    completeWith(.success(hours))
                } catch {
                    completeWith(.failure(.invalidResponse))
                    return
                }
            case .failure(let error):
                completeWith(.failure(error))
            }
        }
    }

    func fetchDay(
        _ day: String,
        completion completeWith: @escaping DayCompletionHandler
    ) {
        let url = configuration.diagnosisKeysURL(day: day)

        session.GET(url) { result in
            switch result {
            case .success(let response):
                guard let dayData = response.body else {
                    completeWith(.failure(.invalidResponse))
                    logError(message: "Failed to download day '\(day)': invalid response")
                    return
                }
                guard let archive = Archive(data: dayData, accessMode: .read) else {
                    logError(message: "Failed to download day '\(day)'. Unable to create zip archive.")
                    completeWith(.failure(.invalidResponse))
                    return
                }
                do {
                    let package = try archive.extractKeyPackage()
//                    package.persist()
                    completeWith(.success(package))
                } catch let error {
                    logError(message: "Failed to download day '\(day)' due to error: \(error).")
                    completeWith(.failure(.invalidResponse))
                }
            case .failure(let error):
                completeWith(.failure(.httpError(error)))
                logError(message: "Failed to download day '\(day)' due to error: \(error).")
            }
        }
    }

    func fetchHour(
        _ hour: Int,
        day: String,
        completion completeWith: @escaping HourCompletionHandler
    ) {
        let url = configuration.diagnosisKeysURL(day: day, hour: hour)
        session.GET(url) { result in
            switch result {
            case .success(let response):
                guard let hourData = response.body else {
                    completeWith(.failure(.invalidResponse))
                    return
                }
                log(message: "got hour: \(hourData.count)")

                guard let archive = Archive(data: hourData, accessMode: .read) else {
                    logError(message: "Failed to download hourData '\(hour)'. Unable to create zip archive.")
                    completeWith(.failure(.invalidResponse))
                    return
                }
                do {
                    let package = try archive.extractKeyPackage()
//                    package.persist()
                    completeWith(.success(package))
                } catch {
                    completeWith(.failure(.invalidResponse))
                }
            case .failure(let error):
                completeWith(.failure(error))
                logError(message: "failed to get day: \(error)")
            }
        }
    }
}

// MARK: Extensions

private extension URLRequest {
    static func submitKeysRequest(
        configuration: HTTPClient.Configuration,
        tan: String,
        keys: [ENTemporaryExposureKey]
    ) throws -> URLRequest {
        let payload = SAP_SubmissionPayload.with {
            $0.keys = keys.compactMap { $0.sapKey }
        }
        let payloadData = try payload.serializedData()
        let url = configuration.submissionURL

        var request = URLRequest(url: url)

        request.setValue(
            tan,
            // TAN code associated with this diagnosis key submission.
            forHTTPHeaderField: "cwa-authorization"
        )

        request.setValue(
            "0",
            // Requests with a value of "0" will be fully processed.
            // Any other value indicates that this request shall be
            // handled as a fake request." ,
            forHTTPHeaderField: "cwa-fake"
        )

        request.setValue(
            "application/x-protobuf",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpMethod = "POST"
        request.httpBody = payloadData

        return request
    }
}

private extension ENExposureConfiguration {
    convenience init(from data: Data) throws {
        self.init()

        let riskscoreParameters = try SAP_RiskScoreParameters(serializedData: data)

//        minimumRiskScore = 0

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

private extension Archive {
    typealias KeyPackage = (bin: Data, sig: Data)
    enum KeyPackageError: Error {
        case binNotFound
        case sigNotFound
    }
    func extractData(from entry: Entry) throws -> Data {
        var data = Data()
        try _ = extract(entry) { slice in
            data.append(slice)
        }
        return data
    }

    func extractKeyPackage() throws -> SAPKeyPackage {
        guard let binEntry = self["export.bin"] else {
            throw KeyPackageError.binNotFound
        }
        guard let sigEntry = self["export.sig"] else {
            throw KeyPackageError.sigNotFound
        }
        return SAPKeyPackage(
            keysBin: try extractData(from: binEntry),
            signature: try extractData(from: sigEntry)
        )
    }
}

private extension SAP_RiskLevel {
    var asNumber: NSNumber {
        NSNumber(value: rawValue)
    }
}

private extension SAP_RiskScoreParameters.TransmissionRiskParameters {
    var asArray: [NSNumber] {
        [appDefined1, appDefined2, appDefined3, appDefined4, appDefined5, appDefined6, appDefined7, appDefined8].map { $0.asNumber }
    }
}

private extension SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
    var asArray: [NSNumber] {
        [ge14Days, ge12Lt14Days, ge10Lt12Days, ge8Lt10Days, ge6Lt8Days, ge4Lt6Days, ge2Lt4Days, ge0Lt2Days].map { $0.asNumber }
    }
}

private extension SAP_RiskScoreParameters.DurationRiskParameters {
    var asArray: [NSNumber] {
        [eq0Min, gt0Le5Min, gt5Le10Min, gt10Le15Min, gt15Le20Min, gt20Le25Min, gt25Le30Min, gt30Min].map { $0.asNumber }
    }
}

private extension SAP_RiskScoreParameters.AttenuationRiskParameters {
    var asArray: [NSNumber] {
        [gt73Dbm, gt63Le73Dbm, gt51Le63Dbm, gt33Le51Dbm, gt27Le33Dbm, gt15Le27Dbm, gt10Le15Dbm, lt10Dbm].map { $0.asNumber }
    }
}
//
extension ENExposureConfiguration {
    class func mock() -> ENExposureConfiguration {
        let config = ENExposureConfiguration()
        config.minimumRiskScore = 0
        config.attenuationWeight = 50
        config.attenuationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        config.daysSinceLastExposureLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        config.daysSinceLastExposureWeight = 50
        config.durationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        config.durationWeight = 50
        config.transmissionRiskLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        config.transmissionRiskWeight = 50
        return config
    }
}
