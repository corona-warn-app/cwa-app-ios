//
//  MockURLSession.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
    private let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    override func resume() {
        completion()
    }
}

class MockUrlSession: URLSession {
    let data: Data?
    let nextResponse: URLResponse?
    let error: Error?

    init(data: Data?, nextResponse: URLResponse?, error: Error?) {
        self.data = data
        self.nextResponse = nextResponse
        self.error = error
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, self.nextResponse, self.error)
        }
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, self.nextResponse, self.error)
        }
    }
}
