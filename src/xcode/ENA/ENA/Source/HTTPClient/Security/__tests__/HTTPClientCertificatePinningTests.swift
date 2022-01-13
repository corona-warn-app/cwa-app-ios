////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HTTPClientCertificatePinningTests: CWATestCase {

	/// Testing ~~certificate~~ public key pinning mechanism on a valid and invalid host.
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
			
			try? XCTSkipIf(response == nil, "Pinning could not be determined because our server is not responding.")
			
			guard let response = response as? HTTPURLResponse else {
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
			let nsError = error as NSError?
			XCTAssertEqual(nsError?.domain, NSURLErrorDomain)
			XCTAssertEqual(nsError?.code, NSURLErrorCancelled)
			taskFinished.fulfill()
		}
		task2.resume()

		waitForExpectations(timeout: 30)
    }

	/// Testing certificate pinning in the main endpoints on `production` and `wru`.
	///
	/// Disabled because the shitty CI & servers don't want to communicate.
	func testAllProductionEndpoints() throws {
		let descriptor = EnvironmentDescriptor.production
		let env = Environments().environment(descriptor)
		let hosts = [
			env.dataDonationURL,
			env.distributionURL,
			env.errorLogSubmissionURL,
			env.submissionURL,
			env.verificationURL
			// TODO: add certificate host URL //swiftlint:disable:this todo
		]

		let coronaWarnURLSessionDelegate = CoronaWarnURLSessionDelegate(
			publicKeyHash: "f30c3959de6b062374f037c505fb3864e1b0678086252ab457ddd97c729d06ab"
		)
		let session = URLSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegate: coronaWarnURLSessionDelegate,
			delegateQueue: .main
		)

		let taskFinished = expectation(description: "[\(descriptor.string)] data tasks finished")
		taskFinished.expectedFulfillmentCount = hosts.count

		hosts.forEach { host in
			let task = session.dataTask(with: host) { _, response, error in
				guard let response = response as? HTTPURLResponse else {
					XCTFail("no http response from \(host)")
					taskFinished.fulfill()
					return
				}
				XCTAssertTrue(
					[200, 403, 404].contains(response.statusCode), // different endpoints, different handling…
					"failed for \(host) (\(response.statusCode))"
				)
				XCTAssertNil(error)
				taskFinished.fulfill()
			}
			task.resume()
		}
		waitForExpectations(timeout: 30)

	}

}
