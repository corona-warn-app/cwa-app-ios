//
//  URLSession+Default.swift
//  ENA
//
//  Created by Kienle, Christian on 16.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension URLSession {
    class func coronaWarnSession() -> URLSession {
        URLSession(
            configuration: .coronaWarnSessionConfiguration(),
            delegate: nil,
            delegateQueue: .main
        )
    }
}
