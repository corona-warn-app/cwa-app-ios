//
//  SAPKeyPackage.swift
//  ENA
//
//  Created by Kienle, Christian on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ZIPFoundation

struct SAPKeyPackage {
    // MARK: Creating a Key Package
    init(keysBin: Data, signature: Data) {
        self.bin = keysBin
        self.signature = signature
    }

    init?(compressedData: Data) {
        guard let archive = Archive(data: compressedData, accessMode: .read) else {
            return nil
        }
        do {
            self = try archive.extractKeyPackage()
        } catch {
            return nil
        }
    }

    // MARK: Properties
    let bin: Data
    let signature: Data
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
