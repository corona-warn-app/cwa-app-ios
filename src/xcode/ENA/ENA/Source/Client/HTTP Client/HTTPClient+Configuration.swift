//
//  BackendConfiguration.swift
//  ENA
//
//  Created by Bormeth, Marc on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension HTTPClient {
    struct Configuration {
        // MARK: Default Instances
        static let production = Configuration(
            apiVersion: "v1",
            country: "DE",
            endpoints: Configuration.Endpoints(
                distribution: .init(
                    baseURL: URL(staticString: "https://localhost/fixme"),
                    requiresTrailingSlash: true
                ),
                submission: .init(
                    baseURL: URL(staticString: "https://localhost/fixme"),
                    requiresTrailingSlash: true
                )
            )
        )
        
        // MARK: Properties
        let apiVersion: String
        let country: String
        let endpoints: Endpoints

        var diagnosisKeysURL: URL {
            endpoints
                .distribution
                .appending(
                    "version",
                    apiVersion,
                    "diagnosis-keys",
                    "country",
                    country
            )
        }

        var availableDaysURL: URL {
            endpoints
                .distribution
                .appending(
                    "version",
                    apiVersion,
                    "diagnosis-keys",
                    "country",
                    country,
                    "date"
            )
        }

        func availableHoursURL(day: String) -> URL {
            endpoints
                .distribution
                .appending(
                    "version",
                    apiVersion,
                    "diagnosis-keys",
                    "country",
                    country,
                    "date",
                    day,
                    "hour"
            )
        }

        func diagnosisKeysURL(day: String, hour: Int) -> URL {
            endpoints
                .distribution
                .appending(
                    "version",
                    apiVersion,
                    "diagnosis-keys",
                    "country",
                    country,
                    "date",
                    day,
                    "hour",
                    String(hour)
            )
        }

        func diagnosisKeysURL(day: String) -> URL {
            endpoints
                .distribution
                .appending(
                    "version",
                    apiVersion,
                    "diagnosis-keys",
                    "country",
                    country,
                    "date",
                    day
            )
        }
        
        var configurationURL: URL {
            endpoints
                .distribution
                .appending(
                    "version",
                    apiVersion,
                    "parameters",
                    "country",
                    country
            )
        }

        var submissionURL: URL {
            endpoints
                .submission
                .appending(
                    "version",
                    apiVersion,
                    "diagnosis-keys"
            )
        }
    }
}

extension HTTPClient.Configuration {
    struct Endpoint {
        // MARK: Properties
        let baseURL: URL
        let requiresTrailingSlash: Bool

        // MARK: Working with an Endpoint
        func appending(_ components: String...) -> URL {
            components.reduce(baseURL) { result, component in
                result.appendingPathComponent(
                    component,
                    isDirectory: self.requiresTrailingSlash
                )
            }
        }
    }
}

extension HTTPClient.Configuration {
    struct Endpoints {
        let distribution: Endpoint
        let submission: Endpoint
    }
}

private extension URL {
    init(staticString: StaticString) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: "\(staticString)")!
    }
}
