//
//  URLSessionConfiguration+Default.swift
//  ENA
//
//  Created by Kienle, Christian on 16.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
    class func coronaWarnSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.httpMaximumConnectionsPerHost = 1 // most reliable
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 5 * 60
        config.httpCookieAcceptPolicy = .never // we don't like cookies - privacy
        config.httpShouldSetCookies = false // we never send cookies
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData // avoid stale data
        return config
    }
}
