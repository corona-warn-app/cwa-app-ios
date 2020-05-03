/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class representing a local server that vends exposure data.
*/

import Foundation
import ExposureNotification

struct CodableDiagnosisKey: Codable, Equatable {
    let keyData: Data
    let rollingStartNumber: ENIntervalNumber
    let transmissionRiskLevel: ENRiskLevel.RawValue
}

struct CodableExposureConfiguration: Codable {
    let minimumRiskScore: ENRiskScore
    let attenuationWeight: Double
    let attenuationScores: [ENRiskScore]
    let daysSinceLastExposureWeight: Double
    let daysSinceLastExposureScores: [ENRiskScore]
    let durationWeight: Double
    let durationScores: [ENRiskScore]
    let transmissionRiskWeight: Double
    let transmissionRiskScores: [ENRiskScore]
}

// Replace this class with your own class that communicates with your server.
class Server {

    static let shared = Server()

    // For testing purposes, this object stores all of the TEKs it receives locally on device
    // In a real implementation, these would be stored on a remote server
    @Persisted(userDefaultsKey: "diagnosisKeys", notificationName: .init("ServerDiagnosisKeysDidChange"), defaultValue: [])
    var diagnosisKeys: [CodableDiagnosisKey]
    func postDiagnosisKeys(_ diagnosisKeys: [ENTemporaryExposureKey], completion: (Error?) -> Void) {

        // Convert keys to something we can encode to JSON and upload
        let codableDiagnosisKeys = diagnosisKeys.compactMap { diagnosisKey -> CodableDiagnosisKey? in
            return CodableDiagnosisKey(keyData: diagnosisKey.keyData, rollingStartNumber: diagnosisKey.rollingStartNumber, transmissionRiskLevel: diagnosisKey.transmissionRiskLevel.rawValue)
        }

        // In a real implementation, these keys would be uploaded with URLSession instead of being saved here.
        // Your server needs to handle de-duplicating keys.
        for codableDiagnosisKey in codableDiagnosisKeys where !self.diagnosisKeys.contains(codableDiagnosisKey) {
            self.diagnosisKeys.append(codableDiagnosisKey)
        }
        completion(nil)
    }
    func getDiagnosisKeys(index: Int, maximumCount: Int, completion: (Result<(diagnosisKeys: [ENTemporaryExposureKey], done: Bool), Error>) -> Void) {

        // In a real implementation, these keys would be retrieved from a server with URLSession
        let end = min(index + maximumCount, self.diagnosisKeys.count)
        let diagnosisKeys = self.diagnosisKeys[index..<end].map { codableDiagnosisKey -> ENTemporaryExposureKey in
            let diagnosisKey = ENTemporaryExposureKey()
            diagnosisKey.keyData = codableDiagnosisKey.keyData
            diagnosisKey.rollingStartNumber = codableDiagnosisKey.rollingStartNumber
            diagnosisKey.transmissionRiskLevel = ENRiskLevel(rawValue: codableDiagnosisKey.transmissionRiskLevel)!
            return diagnosisKey
        }
        completion(.success((diagnosisKeys, end == self.diagnosisKeys.count)))
    }

    func getExposureConfiguration(completion: (Result<ENExposureConfiguration, Error>) -> Void) {

        let dataFromServer = """
        {"minimumRiskScore":0,
        "attenuationWeight":50,
        "attenuationScores":[1, 2, 3, 4, 5, 6, 7, 8],
        "daysSinceLastExposureWeight":50,
        "daysSinceLastExposureScores":[1, 2, 3, 4, 5, 6, 7, 8],
        "durationWeight":50,
        "durationScores":[1, 2, 3, 4, 5, 6, 7, 8],
        "transmissionRiskWeight":50,
        "transmissionRiskScores":[1, 2, 3, 4, 5, 6, 7, 8]}
        """.data(using: .utf8)!

        do {
            let codableExposureConfiguration = try JSONDecoder().decode(CodableExposureConfiguration.self, from: dataFromServer)
            let exposureConfiguration = ENExposureConfiguration()
            exposureConfiguration.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
            exposureConfiguration.attenuationWeight = codableExposureConfiguration.attenuationWeight
            exposureConfiguration.attenuationScores = codableExposureConfiguration.attenuationScores as [NSNumber]
            exposureConfiguration.daysSinceLastExposureWeight = codableExposureConfiguration.daysSinceLastExposureWeight
            exposureConfiguration.daysSinceLastExposureScores = codableExposureConfiguration.daysSinceLastExposureScores as [NSNumber]
            exposureConfiguration.durationWeight = codableExposureConfiguration.durationWeight
            exposureConfiguration.durationScores = codableExposureConfiguration.durationScores as [NSNumber]
            exposureConfiguration.transmissionRiskWeight = codableExposureConfiguration.transmissionRiskWeight
            exposureConfiguration.transmissionRiskScores = codableExposureConfiguration.transmissionRiskScores as [NSNumber]
            completion(.success(exposureConfiguration))
        } catch {
            completion(.failure(error))
        }
    }
}
