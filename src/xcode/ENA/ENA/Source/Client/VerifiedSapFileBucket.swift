//
//  VerifiedSapFileBucket.swift
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

struct VerifiedSapFileBucket {
    // MARK: Creating a signed SAP File Bucket
    init(verifiedPayload: VerifiedPayload) throws {
        self.verifiedPayload = verifiedPayload
        fileBucket = try Sap_FileBucket(serializedData: verifiedPayload.payload)
    }

    init(serializedSignedPayload data: Data) throws {
        try self.init(verifiedPayload: VerifiedPayload(serializedSignedPayload: data))
    }

    // MARK: Properties
    let verifiedPayload: VerifiedPayload
    let fileBucket: Sap_FileBucket

    var files: [Sap_File] { fileBucket.files }

    var appleFiles: [Apple_File] {
        files.map { $0.toAppleFile() }
    }
}
