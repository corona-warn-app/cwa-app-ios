//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class EnvironmentTests: XCTestCase {
	
	func test_AvailableEnvironmentsReturnsEnvironments() {
		let sut_ServerEnvironment = loadTestEnvironment()
		let environments = sut_ServerEnvironment.environments

		XCTAssertEqual(environments.count, 3)
		XCTAssertEqual(environments[0].name, "prod")
		XCTAssertEqual(environments[1].name, "TestEnvironment1")
		XCTAssertEqual(environments[2].name, "TestEnvironment2")
	}

	func test_loadServerEnvironmentReturnesCorrectEnvironment() {
		let sut_ServerEnvironment = loadTestEnvironment()

		["prod", "TestEnvironment1", "TestEnvironment2"].forEach { name in
			let environment = sut_ServerEnvironment.environment(.custom(name))
			XCTAssertEqual(environment.name, name)
		}
	}

	func test_defaultEnvironmentShouldReturnCorrectEnvironment() {
		let sut_ServerEnvironment = loadTestEnvironment()
		let environment = sut_ServerEnvironment.defaultEnvironment()

		XCTAssertEqual(environment.name, "prod")
	}

	private func loadTestEnvironment() -> EnvironmentProviding {
		let testBundle = Bundle(for: EnvironmentTests.self)
		return Environments(bundle: testBundle, resourceName: "TestEnvironments")
	}
}
