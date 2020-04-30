//
//  ExposureVerificationService.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

class ExposureVerificationService : NSObject {
    
    weak var delegate: ExposureVerificationServiceDelegate?
    
    private lazy var downloadSession = URLSession(configuration: URLSessionConfiguration.default,
                                                  delegate: self,
                                                  delegateQueue: nil)
    
    @UserDefaultsStorage(key: "lastProcessedPackageTime", defaultValue: nil)
    static var lastProcessedPackageTime: Date?
    
    func verifyExposureIfNeeded() {
        // Check the timeframe since last succesfull download of a package.
        if !checkLastEVSession() {
            return  // Avoid DDoS by allowing only one request per hour
        }
        
        // Prepare parameter for download task
        let requestParam = formatPackageRequestName()
        
        // Subscribe to notififaction center: Transfer background download, once the user kills the app or move it to background.
        // ...
        
        // Download the diff packages since last update
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

// MARK: - Download & parse packages
extension ExposureVerificationService : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Extract result from file
        do {
            // Copy .tmp file to an accessible URL
            let documentsUrl = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let destinationUrl = documentsUrl.appendingPathComponent(location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            
            // Pass file to PackageManager
            let pm = PackageManager()
            pm.processDownloadedPackages(fileURL: destinationUrl)
            
            // Get result from PackageManager/ExposureVerificationSession + notify delegate
            
            // Filemanager.default.removeItem
        } catch {
            // Handle error
            
            // Notify delegate
            
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Downloading ...")
        // Notify delegate about progress
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }

}
