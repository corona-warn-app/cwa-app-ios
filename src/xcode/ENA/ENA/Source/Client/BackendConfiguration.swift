//
//  BackendConfiguration.swift
//  ENA
//
//  Created by Bormeth, Marc on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct BackendConfiguration {
    // MARK: Properties
    let baseURL: URL
    let apiVersion: String
    let country: String
    var submissionServiceUrl: URL {
        baseURL
            .appendingPathComponent(apiVersion)
            .appendingPathComponent("diagnosis-keys")
    }
}

extension BackendConfiguration {
    static let development = BackendConfiguration(
        baseURL: URL(staticString: "http://distribution-mock-cwa-server.apps.p006.otc.mcs-paas.io"),
        apiVersion: "v1",
        country: "DE"
    )

    static let production = development
}

private extension URL {
    init(staticString: StaticString) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: "\(staticString)")!
    }
}
