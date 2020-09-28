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

class LocalServerEnvironmentTests: XCTestCase {
	
	func test_AvailableEnvironmentsReturnsEnvironments() {
		let sut_LocalServerEnvironment = makeLocalServerEnvironment()
		let environments = sut_LocalServerEnvironment.availableEnvironments()

		XCTAssertEqual(environments.count, 3)
		XCTAssertEqual(environments[0].name, "Default")
		XCTAssertEqual(environments[1].name, "TestEnvironment1")
		XCTAssertEqual(environments[2].name, "TestEnvironment2")
	}

	func test_GetHostsReturnesCorrectHosts() {
		let sut_LocalServerEnvironment = makeLocalServerEnvironment()
		let hosts = sut_LocalServerEnvironment.getHosts(for: "TestEnvironment2")

		XCTAssertEqual(hosts.distributionURL.absoluteString, "https://TestEnvironment2.distribution")
		XCTAssertEqual(hosts.submissionURL.absoluteString, "https://TestEnvironment2.submission")
		XCTAssertEqual(hosts.verificationURL.absoluteString, "https://TestEnvironment2.verification")
	}

	func test_loadServerEnvironmentReturnesCorrectEnvironment() {
		let sut_LocalServerEnvironment = makeLocalServerEnvironment()
		let environment = sut_LocalServerEnvironment.loadServerEnvironment("TestEnvironment1")
		
		XCTAssertEqual(environment.name, "TestEnvironment1")
	}

	func test_defaultEnvironmentShouldReturnCorrectEnvironment() {
		let sut_LocalServerEnvironment = makeLocalServerEnvironment()
		let environment = sut_LocalServerEnvironment.defaultEnvironment()

		XCTAssertEqual(environment.name, "Default")
	}

	private func makeLocalServerEnvironment() -> LocalServerEnvironment {
		let testBundle = Bundle(for: LocalServerEnvironmentTests.self)
		return LocalServerEnvironment(bundle: testBundle, resourceName: "TestServerEnvironments")
	}
}
