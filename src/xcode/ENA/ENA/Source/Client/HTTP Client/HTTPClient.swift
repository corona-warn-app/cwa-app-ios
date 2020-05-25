//
//  HTTPClient.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation
import ExposureNotification

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
                do {
                    completion(try ENExposureConfiguration(from: data))
                    log(message: "Retrieved exposureConfiguation from server")
                } catch {
                    logError(message: "Faild to get exposure configuration: \(error.localizedDescription)")
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
    
    func getTestResult(forDevice registrationToken: String, completion completeWith: @escaping TestResultHandler) {
        let url = configuration.testResultURL
        
        let bodyValues = ["registrationToken":registrationToken]
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(bodyValues)

            session.POST(url, data) {result in
                switch result {
                case .success(let response):
                    guard response.hasAcceptableStatusCode else {
                        completeWith(.failure(.serverError(response.statusCode)))
                        return
                    }
                    guard let testResultResponseData = response.body else {
                        completeWith(.failure(.invalidResponse))
                        logError(message: "Failed to register Device with invalid response")
                        return
                        }
                    do {
                        let decoder = JSONDecoder()
                        let responseDictionary: [String:Int] = try decoder.decode([String:Int].self, from: testResultResponseData)
                        if(responseDictionary["testResult"] != nil){
                            completeWith(.success(responseDictionary["testResult"]!))
                        }else{
                            logError(message: "Failed to register Device with invalid response payload structure")
                            completeWith(.failure(.invalidResponse))
                        }
                    } catch _ {
                        logError(message: "Failed to register Device with invalid response payload structure")
                        completeWith(.failure(.invalidResponse))
                    }
                case .failure(let error):
                    completeWith(.failure(.httpError(error)))
                    logError(message: "Failed to registerDevices due to error: \(error).")
                }
            }
        } catch {
                   completeWith(.failure(.invalidResponse))
                   return
        }
    }
    
    func getTANForExposureSubmit(forDevice registrationToken: String, completion completeWith: @escaping TANHandler) {
        let url = configuration.tanRetrievalURL
        
        let bodyValues = ["registrationToken":registrationToken]
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(bodyValues)
            
            session.POST(url, data) {result in
                switch result {
                case .success(let response):
                    guard response.hasAcceptableStatusCode else {
                        completeWith(.failure(.serverError(response.statusCode)))
                        return
                    }
                    guard let tanResponseData = response.body else {
                        completeWith(.failure(.invalidResponse))
                        logError(message: "Failed to get TAN")
                        logError(message: String(response.statusCode))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let responseDictionary: [String:String] = try decoder.decode([String:String].self, from: tanResponseData)
                        if(responseDictionary["tan"] != nil){
                            completeWith(.success(responseDictionary["tan"]!))
                        }else{
                            logError(message: "Failed to get TAN because of invalid response payload structure")
                            completeWith(.failure(.invalidResponse))
                        }
                    } catch _ {
                        logError(message: "Failed to get TAN because of invalid response payload structure")
                        completeWith(.failure(.invalidResponse))
                    }
                case .failure(let error):
                    completeWith(.failure(.httpError(error)))
                    logError(message: "Failed to get TAN due to error: \(error).")
                }
            }
        } catch {
                   completeWith(.failure(.invalidResponse))
                   return
        }
    }
    
    func getRegistrationToken(forKey key: String, withType type: String, completion completeWith: @escaping RegistrationHandler) {
        
        let url = configuration.registrationURL
        
        let bodyValues = ["key":key,"keyType":type]
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(bodyValues)

            session.POST(url, data) {result in
                switch result {
                case .success(let response):
                    guard response.hasAcceptableStatusCode else {
                        completeWith(.failure(.serverError(response.statusCode)))
                        return
                    }
                    guard let registerResponseData = response.body else {
                        completeWith(.failure(.invalidResponse))
                        logError(message: "Failed to register Device with invalid response")
                        return
                        }
                    do {
                        let decoder = JSONDecoder()
                        let responseDictionary: [String:String] = try decoder.decode([String:String].self, from: registerResponseData)
                        if(responseDictionary["registrationToken"] != nil){
                            completeWith(.success(responseDictionary["registrationToken"]!))
                        }else{
                            logError(message: "Failed to register Device with invalid response payload structure")
                            completeWith(.failure(.invalidResponse))
                        }
                    } catch _ {
                        logError(message: "Failed to register Device with invalid response payload structure")
                        completeWith(.failure(.invalidResponse))
                    }
                case .failure(let error):
                    completeWith(.failure(.httpError(error)))
                    logError(message: "Failed to registerDevices due to error: \(error).")
                }
            }
        } catch {
                   completeWith(.failure(.invalidResponse))
                   return
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
                do {
                    let bucket = try VerifiedSapFileBucket(serializedSignedPayload: dayData)
                    completeWith(.success(bucket))
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
                do {
                    let bucket = try VerifiedSapFileBucket(serializedSignedPayload: hourData)
                    completeWith(.success(bucket))
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
        let payload = Sap_SubmissionPayload.with {
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

private extension Sap_RiskLevel {
    var asNumber: NSNumber {
        NSNumber(value: rawValue)
    }
}

private extension Sap_RiskScoreParameters.TransmissionRiskParameters {
    var asArray: [NSNumber] {
        [appDefined1, appDefined2, appDefined3, appDefined4, appDefined5, appDefined6, appDefined7, appDefined8].map { $0.asNumber }
    }
}

private extension Sap_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
    var asArray: [NSNumber] {
        [ge14Days, ge12Lt14Days, ge10Lt12Days, ge8Lt10Days, ge6Lt8Days, ge4Lt6Days, ge2Lt4Days, ge0Lt2Days].map { $0.asNumber }
    }
}

private extension Sap_RiskScoreParameters.DurationRiskParameters {
    var asArray: [NSNumber] {
        [eq0Min, gt0Le5Min, gt5Le10Min, gt10Le15Min, gt15Le20Min, gt20Le25Min, gt25Le30Min, gt30Min].map { $0.asNumber }
    }
}

private extension Sap_RiskScoreParameters.AttenuationRiskParameters {
    var asArray: [NSNumber] {
        [gt73Dbm, gt63Le73Dbm, gt51Le63Dbm, gt33Le51Dbm, gt27Le33Dbm, gt15Le27Dbm, gt10Le15Dbm, lt10Dbm].map { $0.asNumber }
    }
}
