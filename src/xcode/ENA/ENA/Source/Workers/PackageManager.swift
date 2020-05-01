//
//  PackageManager.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

fileprivate extension Data {
    static func randomKeyData() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
          if(SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) != 0) {
              fatalError("this should never happen")
          }
        return Data(bytes)
    }

}

class PackageManager: NSObject {

    enum Mode {
        case production
        case development
    }

    typealias DiagnosisKeysResult = Result<[ENTemporaryExposureKey], Error>
    typealias CompletionHandler = (DiagnosisKeysResult) -> Void

    typealias SendCompletionHandler = (Error?) -> Void


    func diagnosisKeys(since lastSyncDate: Date, completionHandler completeWith: @escaping CompletionHandler) {
        switch mode {
        case .development:
            developmentDiagnosisKeys(since: lastSyncDate, completionHandler: completeWith)
        case .production:
            producationDiagnosisKeys(since: lastSyncDate, completionHandler: completeWith)
        }
    }

    func sendDiagnosisKeys(_ diagnosisKeys: [Data], tan: String, completionHandler completeWith: @escaping SendCompletionHandler) {
           switch mode {
           case .development:
            // In development we simply assume that everything just works.
            completeWith(/* error */ nil)
           case .production:
            productionSendDiagnosisKeys(diagnosisKeys, tan: tan, completionHandler: completeWith)
           }
       }

    private func productionSendDiagnosisKeys(_ keys: [Data], tan: String, completionHandler completeWith: @escaping SendCompletionHandler) {
        // TODO: implementation missing.
        fatalError("not implemented")
    }


    private func producationDiagnosisKeys(since: Date, completionHandler completeWith: @escaping CompletionHandler) {
        // TODO: implementation missing
        fatalError("not implemented")
        /// Example that roughly shows what here should happen:
        /// ```swift
        ///    let url = URL(string: "https://0.0.0.0/\(since)/file.proto")!
        ///    downloadSession.dataTask(with: url) { (_, _, _) in
        ///        completeWith(.success([]))
        ///    }.resume()
        /// ```
    }

    private func developmentDiagnosisKeys(since: Date, completionHandler completeWith: @escaping CompletionHandler) {
        let keyIndices = 0...10
        let keys: [ENTemporaryExposureKey] = keyIndices.map({ _ in
            let key = ENTemporaryExposureKey()
            key.keyData = Data.randomKeyData()
            return key
        })
        completeWith(.success(keys))
    }

    private lazy var downloadSession = URLSession(configuration: URLSessionConfiguration.default,
                                                  delegate: self,
                                                  delegateQueue: .main)

//    private weak var delegate: PackageManagerDelegate?
    private let mode: Mode
    init(mode: Mode) {
//        self.delegate = delegate
        self.mode = mode
    }
}

// MARK: - Download & parse packages
extension PackageManager : URLSessionDownloadDelegate {
    // TODO: move this to the production implementation at some point
    // TODO: think about encryption
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
}
