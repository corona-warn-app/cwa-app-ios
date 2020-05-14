//
//  Client.swift
//  ENA
//
//  Created by Bormeth, Marc on 05.05.20.
//

import Foundation
import ExposureNotification

/// Describes how to interfact with the backend.
protocol Client {
    // MARK: Types
    typealias SubmitKeysCompletionHandler = (SubmissionError?) -> Void
    typealias FetchKeysCompletionHandler = (Result<[URL], Error>) -> Void

    // MARK: Interacting with a Client

    // MARK: Getting the Configuration
    typealias ExposureConfigurationCompletionHandler = (Result<ENExposureConfiguration, Error>) -> Void

    /// Gets the remove exposure configuration. See `ENExposureConfiguration` for more details
    /// Parameters:
    /// - completion: Will be called with the remove configuration or an error if something went wrong. The completion handler will always be called on the main thread.
    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler)

    /// Submits exposure keys to the backend. This makes the local information available to the world so that the risk of others can be calculated on their local devices.
    /// Parameters:
    /// - keys: An array of `ENTemporaryExposureKey`s  to submit to the backend.
    /// - tan: A transaction number
    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler)

    /// `completion` will be called on the main queue.
    func fetch(completion: @escaping FetchKeysCompletionHandler)
}

enum SubmissionError: Error {
    case generalError
    case networkError
    case invalidPayloadOrHeaders
    case invalidTan
}
