//
//  PackageManager.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

class PackageManager: NSObject {

    private lazy var downloadSession = URLSession(configuration: URLSessionConfiguration.default,
                                                  delegate: self,
                                                  delegateQueue: nil)

    func downloadDiagnosisKeys(urlSuffix: String) {
        // Add either completion handler or delegate to notify ExposureDetectionService

        // Download the diff packages since last update
        let task = downloadSession.downloadTask(with: URL(string: "https://file-examples.com/wp-content/uploads/2017/02/file_example_CSV_5000.csv")!)
        task.resume()
    }
}

// MARK: - Download & parse packages
extension PackageManager : URLSessionDownloadDelegate {

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
