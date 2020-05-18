//
//  HTTPClient+Response.swift
//  ENA
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension HTTPClient {
    /// Represents a response produced by `HTTPClient`.
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
