//
//  Config.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation

struct BackendConfig {
    let serverUrl: String
    let apiVersion: String
}

let backendMockConfig = BackendConfig(
    serverUrl: "http://localhost:8080",
    apiVersion: "v1"
)
