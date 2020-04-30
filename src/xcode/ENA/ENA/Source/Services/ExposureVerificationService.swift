//
//  ExposureVerificationService.swift
//  ENA
//
//  Created by Hu, Hao on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import MockENFramework

class ExposureVerificationService : NSObject {
    
    static var shared = ExposureVerificationService()
    
    weak var delegate: ExposureVerificationServiceDelegate?
    
    private lazy var downloadSession = URLSession(configuration: URLSessionConfiguration.default,
                                                  delegate: self,
                                                  delegateQueue: nil)
    
    @UserDefaultsStorage(key: "lastProcessedPackageTime", defaultValue: nil)
    static var lastProcessedPackageTime: Date?
    
    func verifyExposure() {
        // Check the timeframe since last succesfull download of a package.
        if (!checkLastEVSession()) {
            return  // Avoid DDoS by allowing only one request per hour
        }
        
        // Prepare parameter for download task
        let requestParam = formatPackageRequestName()
        
        // Download the diff packages since last update
        // Consider: Transfer background download, once the user kill the app or move it to background.
        let task = downloadSession.downloadTask(with: URL(string: "https://file-examples.com/wp-content/uploads/2017/02/file_example_CSV_5000.csv")!)
        task.resume()
        
    }
    
    // MARK: - Private helper methods
    private func formatPackageRequestName() -> String {
        // Case 1: First request -> Fetch last 14 days
        // Case 2: Request within 2 weeks from last request -> just format timestamp
        // Case 3: Last request older than upper threshold -> limit to threshold
        return "06-03-22"
    }
    
    private func checkLastEVSession() -> Bool {
        let now = Date()
        guard let lastProcessedPackageTime = Self.lastProcessedPackageTime else{
            return true  // No date stored -> first session
        }
        
        let hoursSinceLastRequest = now.timeIntervalSince(lastProcessedPackageTime) / 3600

        if (hoursSinceLastRequest > 1) {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: - Download & parse packages
extension ExposureVerificationService : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Extract result from file
        do {
            let documentsUrl = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: location,
                                        create: false)
            let destinationUrl = documentsUrl.appendingPathComponent(location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            let content = try String(contentsOf: destinationUrl)
            print(content)
            
        } catch {
            // Notify delegate
            print("Error: \(error)")
        }
        
        // Format result to be able to use Apple's API
        
        // Create the ExposureDetectionSession from API
        
        // Call addDiagnosisKey to get the result
        
        // Notify delegate about the result
        
        // Filemanager.default.removeItem
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Downloading ...")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }

}
