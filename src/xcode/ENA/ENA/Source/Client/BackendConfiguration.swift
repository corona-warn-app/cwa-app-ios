//
//  BackendConfiguration.swift
//  ENA
//
//  Created by Bormeth, Marc on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct BackendConfiguration {
    struct Endpoints {
        let distribution: URL
        let submission: URL
    }

    // MARK: Properties
    let apiVersion: String
    let country: String
    let endpoints: Endpoints

    var diagnosisKeysURL: URL {
        endpoints
            .distribution
            .appendingDirectory("version")
            .appendingDirectory(apiVersion)
            .appendingDirectory("diagnosis-keys")
    }

    var regionalDiagnosisKeysURL: URL {
        diagnosisKeysURL
            .appendingDirectory("country")
            .appendingDirectory(country)
    }

    var regionalConfigurationURL: URL {
        endpoints
            .distribution
            .appendingDirectory("version")
            .appendingDirectory(apiVersion)
            .appendingDirectory("parameters")
            .appendingDirectory("country")
            .appendingDirectory(country)
    }
}

private extension URL {
    // TODO: This is wrong on production.
    // Mock server reuires trailing slash
    // Produiction does not.
    func appendingDirectory(_ directory: String) -> URL {
        appendingPathComponent(directory, isDirectory: true)
    }
}

extension BackendConfiguration {
    init(endpoints: Endpoints) {
        self.init(apiVersion: "v1", country: "DE", endpoints: endpoints)
    }
    static let production = BackendConfiguration(
        apiVersion: "v1",
        country: "DE",
        endpoints: Endpoints(
            distribution: URL(staticString: "https://fixme.coronawarn.app"),
            submission: URL(staticString: "https://fixme.coronawarn.app")
        )
    )

    // TODO: Fix this
//    static let production = development
}

private extension URL {
    init(staticString: StaticString) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: "\(staticString)")!
    }
}
