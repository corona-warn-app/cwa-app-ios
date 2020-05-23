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
    init(rootDir: URL, keyPackages: [SAPKeyPackage]) {
        self.rootDir = rootDir
        self.keyPackages = keyPackages
    }

    // MARK: Properties
    let rootDir: URL
    let keyPackages: [SAPKeyPackage]

    // MARK: Interacting with the Writer
    typealias WithDiagnosisKeyURLsHandler = (
        _ diagnosisKeyURLs: [URL],
        _ done: @escaping DoneHandler
        ) -> Void

    typealias DoneHandler = () -> Void

    func with(handler: WithDiagnosisKeyURLsHandler) {
        var writtenURLs = [URL]()

        func cleanup() {
            let fileManager = FileManager()
            for writtenURL in writtenURLs {
                try? fileManager.removeItem(at: writtenURL)
            }
            return
        }

        var needsCleanupInDone = true

        for keyPackage in keyPackages {
                    let filename = UUID().uuidString

            do {
                writtenURLs.append(
                    try keyPackage.writeKeysEntry(toDirectory: rootDir, filename: filename)
                )
                writtenURLs.append(
                    try keyPackage.writeSignatureEntry(toDirectory: rootDir, filename: filename)
                )
            } catch {
                cleanup()
                writtenURLs = [] // we need to set this to an empty array
                needsCleanupInDone = false
            }
        }

        handler(writtenURLs) {
            // This is executed when the app is finished.
            // needsCleanupInDone will be true if the writer has cleaned up already due to errors.
            guard needsCleanupInDone else {
                return
            }
            cleanup()
        }
    }
}

private extension SAPKeyPackage {
    func writeSignatureEntry(toDirectory directory: URL, filename: String) throws -> URL {
        let url = directory.appendingPathComponent(filename).appendingPathExtension("sig")
        try signature.write(to: url)
        return url
    }

    func writeKeysEntry(toDirectory directory: URL, filename: String) throws -> URL {
        let url = directory.appendingPathComponent(filename).appendingPathExtension("bin")
        try bin.write(to: url)
        return url
    }
}
