//
//  Sap_Model.swift
//  ENATests
//
//  Created by Kienle, Christian on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
@testable import ENA

extension Sap_FileBucket {
    static func empty() -> Sap_FileBucket {
        Sap_FileBucket.with { $0.files = [] }
    }

}

extension Sap_File {
    static func empty() -> Sap_File {
        Sap_File.with { $0.keys = [] }
    }
}

extension Sap_SignedPayload {
    static func empty() -> Sap_SignedPayload {
        Sap_SignedPayload.with {
            $0.payload = Data()
        }
    }
}
