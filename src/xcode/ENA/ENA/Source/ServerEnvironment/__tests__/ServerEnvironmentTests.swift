//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ServerEnvironmentTests: XCTestCase {
	
	func test_AvailableEnvironmentsReturnsEnvironments() {
		let sut_ServerEnvironment = makeServerEnvironment()
		let environments = sut_ServerEnvironment.availableEnvironments()

		XCTAssertEqual(environments.count, 3)
		XCTAssertEqual(environments[0].name, "Default")
		XCTAssertEqual(environments[1].name, "TestEnvironment1")
		XCTAssertEqual(environments[2].name, "TestEnvironment2")
	}

	func test_loadServerEnvironmentReturnesCorrectEnvironment() {
		let sut_ServerEnvironment = makeServerEnvironment()
		let environment = sut_ServerEnvironment.environment("TestEnvironment1")
		
		XCTAssertEqual(environment.name, "TestEnvironment1")
	}

	func test_defaultEnvironmentShouldReturnCorrectEnvironment() {
		let sut_ServerEnvironment = makeServerEnvironment()
		let environment = sut_ServerEnvironment.defaultEnvironment()

		XCTAssertEqual(environment.name, "Default")
	}

	private func makeServerEnvironment() -> ServerEnvironment {
		let testBundle = Bundle(for: ServerEnvironmentTests.self)
		return ServerEnvironment(bundle: testBundle, resourceName: "TestServerEnvironments")
	}
}
