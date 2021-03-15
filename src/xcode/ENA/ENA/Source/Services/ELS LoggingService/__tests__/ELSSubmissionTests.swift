////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ELSSubmissionTests: XCTestCase {

	// Disabled; manual usage only
    func testELSAuthentication() throws {
		let store = MockTestStore()
		let client = HTTPClient(serverEnvironmentProvider: store)

		let onPPACToken = expectation(description: "onPPAC")
		let onUpload = expectation(description: "onUpload")

		#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		#else
		let deviceCheck = PPACDeviceCheck()
		#endif
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken { result in
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let ppacToken):
				let logFile = "Dummy log".data(using: .utf8) ?? Data()

				client.submit(logFile: logFile, uploadToken: ppacToken, isFake: false, forceApiTokenHeader: false) { result in
					switch result {
					case .failure(let error):
						XCTFail(error.localizedDescription)
					case .success(let response):
						debugPrint(response.id)
						debugPrint(response.hash)
					}
					onUpload.fulfill()
				}
			}
			onPPACToken.fulfill()
		}

		waitForExpectations(timeout: 60)
    }
}
