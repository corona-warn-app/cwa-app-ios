//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class EnvironmentTests: XCTestCase {
	
	func test_AvailableEnvironmentsReturnsEnvironments() {
		let sut_ServerEnvironment = loadTestEnvironment()
		let environments = sut_ServerEnvironment.environments

		XCTAssertEqual(environments.count, 4)
		XCTAssertEqual(environments[0].name, "TestEnvironment0")
		XCTAssertEqual(environments[1].name, "TestEnvironment1")
		XCTAssertEqual(environments[2].name, "TestEnvironment2")
		XCTAssertEqual(environments[3].name, "prod")
	}

	func test_loadServerEnvironmentReturnesCorrectEnvironment() {
		let testEnvironments = loadTestEnvironment()

		["prod", "TestEnvironment0", "TestEnvironment1", "TestEnvironment2"].shuffled().forEach { name in
			let environment = testEnvironments.environment(.custom(name))
			XCTAssertEqual(environment.name, name)
		}


	}

	func test_defaultEnvironmentShouldReturnCorrectEnvironment() {
		let testEnvironments = loadTestEnvironment()
		// First environment is default. In non-`DEBUG` builds this is always 'prod'
		for _ in 0..<10 {
			let e = Environments(environments: testEnvironments.environments.shuffled())
			XCTAssertEqual(e.defaultEnvironment().name, e.environments[0].name)
		}

		// test for the production key/name: `.production == 'prod'` 
		XCTAssertEqual(testEnvironments.environment(.production).name, "prod")
	}

	private func loadTestEnvironment() -> EnvironmentProviding {
		let testBundle = Bundle(for: EnvironmentTests.self)
		return Environments(bundle: testBundle, resourceName: "TestEnvironments")
	}
}
