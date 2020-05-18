//
//  URLSession+Convenience.swift
//  ENA
//
//  Created by Kienle, Christian on 17.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension URLSession {
    typealias Completion = Response.Completion

    // This method executes HTTP GET requests.
    func GET(_ url: URL, completion: @escaping Completion) {
        response(for: URLRequest(url: url), completion: completion)
    }

    // This method executes HTTP requests.
    // It does some additional checks - purely for convenience:
    // - if there is an error it aborts
    // - if there is either no HTTP body and/or HTTPURLResponse it aborts
    func response(
        for request: URLRequest,
        completion: @escaping Completion
    ) {
        dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.httpError(error)))
                return
            }
            guard
                let data = data,
                let response = response as? HTTPURLResponse
                else {
                    completion(.failure(.noResponse))
                    return
            }
            completion(
                .success(
                    .init(body: data, statusCode: response.statusCode)
                )
            )
        }
        .resume()
    }
}

extension URLSession {
    /// Represents a response produced by the convenience extensions on `URLSession`.
    struct Response {
        // MARK: Properties
        let body: Data?
        let statusCode: Int

        // MARK: Working with a Response
        var hasAcceptableStatusCode: Bool {
            type(of: self).acceptableStatusCodes.contains(statusCode)
        }

        private static let acceptableStatusCodes = (200...299)
    }
}

extension URLSession.Response {
    /// Raised when `URLSession` was unable to get an actual response.
    enum Failure: Error {
        /// The session received an `Error`. In that case the body and response is discarded.
        case httpError(Error)
        /// The session did not receive an error but nor either an `HTTPURLResponse`/HTTP body.
        case noResponse
        case invalidResponse
    }

    typealias Completion = (Result<URLSession.Response, Failure>) -> Void
}
