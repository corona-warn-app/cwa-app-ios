//
//  SAPKeyPackage.swift
//  ENA
//
//  Created by Kienle, Christian on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct VerifiedPayload {
    // MARK: Creating
    init(signedPayload: Sap_SignedPayload) throws {
        self.signedPayload = signedPayload
    }

    init(serializedSignedPayload data: Data) throws {
        try self.init(
            signedPayload: try Sap_SignedPayload(serializedData: data)
        )
    }

    // MARK: Properties
    let signedPayload: Sap_SignedPayload
    var payload: Data {
        signedPayload.payload
    }
}

struct SAPKeyPackage {

    init(keysBin: Data, signature: Data) {
        self.keysBin = keysBin
        self.signature = signature
    }

    // MARK: Properties
    let keysBin: Data
    let signature: Data

    func persist() {
        // TODO: Use local DB here later

        let uuid = UUID().uuidString
        let directory = URL(fileURLWithPath: "local/")  // TODO

        do {
            try keysBin.write(to: directory.appendingPathComponent("\(uuid).bin"))
            try signature.write(to: directory.appendingPathComponent("\(uuid).sig"))
        } catch {
            logError(message: "Failed to store downloaded files")
        }

    }

}
