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
    // MARK: Creating a Key Package
    init(keysBin: Data, signature: Data) {
        self.keysBin = keysBin
        self.signature = signature
    }

    // MARK: Properties
    let keysBin: Data
    let signature: Data
}
