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
    var serverUrl = "http://localhost:8080"
    var apiVersion = "v1"
    var country = "DE"
}
