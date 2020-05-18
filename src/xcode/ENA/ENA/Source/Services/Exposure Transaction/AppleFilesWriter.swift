//
//  AppleFilesWriter.swift
//  ENA
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

final class AppleFilesWriter {
    // MARK: Creating a Writer
    init(rootDir: URL, files: [Apple_File]) {
        self.rootDir = rootDir
        self.files = files
    }

    // MARK: Properties
    let rootDir: URL
    let files: [Apple_File]

    // MARK: Interacting with the Writer
    typealias WithDiagnosisKeyURLsHandler = (
        _ diagnosisKeyURLs: [URL],
        _ done: @escaping DoneHandler
    ) -> Void

    typealias DoneHandler = () -> Void

    func with(handler: WithDiagnosisKeyURLsHandler) {
        let writtenUrls = files
            .enumerated()
            .map { write(file: $1, id: $0) }
            .compactMap { $0 }

        func cleanup() {
            let fileManager = FileManager()
            for writtenUrl in writtenUrls {
                try? fileManager.removeItem(at: writtenUrl)
            }
            return
        }
        
        handler(writtenUrls) {
            // This is executed when the app is finished.
            // Here we could clean up the files
            cleanup()
        }
    }

    private func write(file: Apple_File, id: Int) -> URL? {
        let url = rootDir.appendingPathComponent("\(id)").appendingPathExtension("proto")
        do {
            try file.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}

extension Apple_File {
    func write(to url: URL) throws {
        try serializedData().write(to: url)
    }
}
