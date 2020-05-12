//
//  Config.swift
//  ENA
//
//  Created by Bormeth, Marc on 10.05.20.
//

import Foundation

protocol BackendConfig {
    var distributionServerUrl: String { get }
    var apiVersion: String { get }
    var country: String { get }
    var submissionServiceUrl: String { get }
}

struct MockBackendConfig: BackendConfig {
    var distributionServerUrl = "http://distribution-mock-cwa-server.apps.p006.otc.mcs-paas.io"
    var apiVersion = "v1"
    var country = "DE"

    var submissionServiceUrl: String { return "http://submission-cwa-server.apps.p006.otc.mcs-paas.io/version/\(apiVersion)/diagnosis-keys" }
}
