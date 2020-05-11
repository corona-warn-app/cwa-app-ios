//
//  Config.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation

protocol BackendConfig {
    var serverUrl: String { get }
    var apiVersion: String { get }
    var country: String { get }
}

struct MockBackendConfig: BackendConfig {
    var serverUrl = "http://distribution-mock-cwa-server.apps.p006.otc.mcs-paas.io"
    var apiVersion = "v1"
    var country = "DE"
}
