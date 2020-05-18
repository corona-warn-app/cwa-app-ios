//
//  HTTPClientPrimitiveTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import XCTest
@testable import ENA

final class HTTPClientPrimitiveTests: XCTestCase {
    func testExecuteRequest_Success() {
        let url = URL(staticString: "https://localhost:8080")

        let data = "hello".data(using: .utf8)
        let session = MockUrlSession(
            data: data,
            response: HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            error: nil
        )
        let request = URLRequest(url: url)

        let client = HTTPClient(
            configuration: BackendConfiguration(
                endpoints: .init(
                    distribution: URL(staticString: "https://localhost:8080/dist"),
                    submission: URL(staticString: "https://localhost:8080/submit")
                )
            ),
            session: session
        )

        let expectation = self.expectation(description: "Success")
        client.response(for: request) { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.body)
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(response.body, data)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("should not fail but did with: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testExecuteRequest_SuccessAcceptsNotFound() {
        let url = URL(staticString: "https://localhost:8080")

        let data = "hello".data(using: .utf8)
        let session = MockUrlSession(
            data: data,
            response: HTTPURLResponse(
                url: url,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            ),
            error: nil
        )
        let request = URLRequest(url: url)

        let client = HTTPClient(
            configuration: BackendConfiguration(
                endpoints: .init(
                    distribution: URL(staticString: "https://localhost:8080/dist"),
                    submission: URL(staticString: "https://localhost:8080/submit")
                )
            ),
            session: session
        )

        let expectation = self.expectation(description: "Success")
        client.response(for: request) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, 404)
                XCTAssertEqual(response.body, data)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("should not fail but did with: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testExecuteRequest_FailureWithError() {
          let url = URL(staticString: "https://localhost:8080")
        let notConnectedError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: nil
        )
          let data = "hello".data(using: .utf8)
          let session = MockUrlSession(
              data: data,
              response: HTTPURLResponse(
                  url: url,
                  statusCode: 200,
                  httpVersion: nil,
                  headerFields: nil
              ),
              error: notConnectedError
          )
          let request = URLRequest(url: url)

          let client = HTTPClient(
              configuration: BackendConfiguration(
                  endpoints: .init(
                      distribution: URL(staticString: "https://localhost:8080/dist"),
                      submission: URL(staticString: "https://localhost:8080/submit")
                  )
              ),
              session: session
          )

          let expectation = self.expectation(description: "Fails")
          client.response(for: request) { result in
            switch result {
            case .success:
                XCTFail("should succeed")
            case .failure:
                expectation.fulfill()
              }
          }

          waitForExpectations(timeout: 1.0)
      }
}
