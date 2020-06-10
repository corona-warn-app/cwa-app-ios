// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

@testable import ENA
import XCTest

final class URLSessionConvenienceTests: XCTestCase {
	func testExecuteRequest_Success() {
		let url = URL(staticString: "https://localhost:8080")

		let data = Data("hello".utf8)
		let session = MockUrlSession(
			data: data,
			nextResponse: HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			),
			error: nil
		)

		let request = URLRequest(url: url)

		let expectation = self.expectation(description: "Success")
		session.response(for: request) { result in
			switch result {
			case let .success(response):
				XCTAssertNotNil(response.body)
				XCTAssertEqual(response.statusCode, 200)
				XCTAssertEqual(response.body, data)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("should not fail but did with: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func testExecuteRequest_SuccessAcceptsNotFound() {
		let url = URL(staticString: "https://localhost:8080")

		let data = Data("hello".utf8)
		let session = MockUrlSession(
			data: data,
			nextResponse: HTTPURLResponse(
				url: url,
				statusCode: 404,
				httpVersion: nil,
				headerFields: nil
			),
			error: nil
		)
		let request = URLRequest(url: url)

		let expectation = self.expectation(description: "Success")
		session.response(for: request) { result in
			switch result {
			case let .success(response):
				XCTAssertEqual(response.statusCode, 404)
				XCTAssertEqual(response.body, data)
				expectation.fulfill()
			case let .failure(error):
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
		let data = Data("hello".utf8)
		let session = MockUrlSession(
			data: data,
			nextResponse: HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			),
			error: notConnectedError
		)
		let request = URLRequest(url: url)

		let expectation = self.expectation(description: "Fails")
		session.response(for: request) { result in
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
