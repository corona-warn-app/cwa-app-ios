////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HTTPClientCertificatePinningTests: XCTestCase {

    func testPinning() throws {
		let coronaWarnURLSessionDelegate = CoronaWarnURLSessionDelegate(
			publicKeyHash: "f30c3959de6b062374f037c505fb3864e1b0678086252ab457ddd97c729d06ab"
		)
		let session = URLSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegate: coronaWarnURLSessionDelegate,
			delegateQueue: .main
		)

		let validURL = try XCTUnwrap(URL(string: "https://svc90.main.px.t-online.de"))
		let invalidURL = try XCTUnwrap(URL(string: "https://example.com"))

		let taskFinished = expectation(description: "data task finished")
		taskFinished.expectedFulfillmentCount = 2 // 1x valid, 1x invalid

		let task1 = session.dataTask(with: validURL) { _, response, error in
			guard let response = response as? HTTPURLResponse else {
				XCTFail("no http response")
				taskFinished.fulfill()
				return
			}
			XCTAssertEqual(response.statusCode, 200)
			XCTAssertNil(error)
			taskFinished.fulfill()
		}
		task1.resume()

		let task2 = session.dataTask(with: invalidURL) { data, response, error in
			// no data, no response (because no request)
			XCTAssertNil(data)
			XCTAssertNil(response)

			// failed pinning results in a 'cancelled' error
			let error = error as NSError?
			XCTAssertEqual(error?.domain, NSURLErrorDomain)
			XCTAssertEqual(error?.code, NSURLErrorCancelled)
			taskFinished.fulfill()
		}
		task2.resume()

		waitForExpectations(timeout: 30)
    }

}
