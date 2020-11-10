//
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
