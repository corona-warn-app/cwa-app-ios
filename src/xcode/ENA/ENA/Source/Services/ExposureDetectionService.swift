//
//  ExposureDetectionService.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

class ExposureDetectionService {
    
    private weak var delegate: ExposureDetectionServiceDelegate?
    private var queue: DispatchQueue
    private var sessionStartTime: Date?
    
    @UserDefaultsStorage(key: "lastProcessedPackageTime", defaultValue: nil)
    static var lastProcessedPackageTime: Date?
    
    init(delegate: ExposureDetectionServiceDelegate?) {
        self.delegate = delegate
        self.queue = DispatchQueue(label: "com.sap.exposureDetection")
    }
    
    func verifyExposureIfNeeded() {
        // Check the timeframe since last succesfull download of a package.
        if !checkLastEVSession() {
            return  // Avoid DDoS by allowing only one request per hour
        }
        
        self.sessionStartTime = Date()
        
        // Prepare parameter for download task
        let requestParam = formatPackageRequestName()
        
        let pm = PackageManager(mode: .development)
        pm.diagnosisKeys(since: Date()) { result in
            // todo
            switch result {
            case .success(let keys):
                self.startExposureDetectionSession(diagnosisKeys: keys)
            case .failure(_):
                // TODO
                print("fail")
            }
        }
        
    }
    
    // MARK: - Private helper methods
    private func formatPackageRequestName() -> String {
        // Case 1: First request -> Fetch last 14 days
        // Case 2: Request within 2 weeks from last request -> just format timestamp
        // Case 3: Last request older than upper threshold -> limit to threshold
        return "06-03-22"
    }
    
    private func checkLastEVSession() -> Bool {
        guard let lastProcessedPackageTime = Self.lastProcessedPackageTime else{
            return true  // No date stored -> first session
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour], from: lastProcessedPackageTime, to: Date())
        let hoursSinceLastRequest = dateComponents.hour ?? 0
        
        // Only allow one request per hour
        return hoursSinceLastRequest > 1
    }
    
}

// MARK: - PackageManagerDelegate
//extension ExposureDetectionService: PackageManagerDelegate {
//    func didDownloadPackages(_ sender: PackageManager, result: [ENTemporaryExposureKey]) {
//        startExposureDetectionSession(diagnosisKeys: result)
//    }
//}

// MARK: - Exposure Detection Session
extension ExposureDetectionService {
    func startExposureDetectionSession(diagnosisKeys: [ENTemporaryExposureKey]) {
        let session = ENExposureDetectionSession()
        
        session.activate() { error in
            if error != nil {
                // Handle error
                return
            }
        }
        
        // Call addDiagnosisKeys with up to maxKeyCount keys
        queue.async {
            let addDiagnosisKeysRetVal = self.addKeys(session, diagnosisKeys)
            DispatchQueue.main.async {
                guard addDiagnosisKeysRetVal == nil else {
                    self.delegate?.didFailWithError(self, error: addDiagnosisKeysRetVal!)
                    return
                }
                // Get result from session
                session.finishedDiagnosisKeys { (summary, error) in
                    guard error == nil else {
                        self.delegate?.didFailWithError(self, error: error! )
                        return
                    }
                    guard let summary = summary else {
                        return
                    }
                    self.delegate?.didFinish(self, result: summary)
                    
                    if self.sessionStartTime != nil {
                        Self.lastProcessedPackageTime = self.sessionStartTime!
                    }
                }
            }
            
        }
    }
    
    func addKeys(_ session: ENExposureDetectionSession, _ keys: [ENTemporaryExposureKey]) -> Error? {
        var index = 0
        var returnValue: Error?
        while index < keys.count {
            let semaphore = DispatchSemaphore(value: 0)
            let endIndex = index + session.maximumKeyCount > keys.count ? keys.count : index + session.maximumKeyCount
            let slice = keys[index..<endIndex]
            
            session.addDiagnosisKeys(Array(slice)) { (error) in
                guard error == nil else {
                    returnValue = error
                    semaphore.signal()
                    return
                }
                semaphore.signal()
                
            }
            semaphore.wait()
            if returnValue != nil {
                return returnValue
            }
            index += session.maximumKeyCount
        }
        return returnValue
    }
}
