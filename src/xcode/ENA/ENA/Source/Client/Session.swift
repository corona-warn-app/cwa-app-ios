//
//  Session.swift
//  ENA
//
//  Created by Kienle, Christian on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

/// A task that can be executed by a `Session`. In practice this will just be an `URLSessionDataTask`.
protocol SessionTask: AnyObject {
    func resume()
}

/// A `Session` that is able to create paused `SessionTasks`.
///
/// This protocol only exists to make testing classes that depend on a session easier. In practice this will be an instance of
/// `URLSession`.
protocol Session: AnyObject {
    /// Creates and returns a `SessionTask` that is paused by default.
    ///
    /// In practice this method simply calls `dataTask(with:completionHandler:)` of `URLSession` and thats it. It has been given a different name in order to avoid ambiguities.
    func sessionTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> SessionTask
}

/// `URLSessionDataTask` already confirms to `SessionTask`. Nothing to do here.
extension URLSessionDataTask: SessionTask {}

extension URLSession: Session {
    /// Creates and returns a paused `SessionTask`.
    ///
    /// As described earlier, this method just redirects everything to `URLSession`.
    func sessionTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> SessionTask {
        dataTask(with: url, completionHandler: completionHandler)
    }
}
