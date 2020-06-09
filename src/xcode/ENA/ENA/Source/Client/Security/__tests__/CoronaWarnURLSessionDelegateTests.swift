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

class CoronaWarnURLSessionDelegateTests: XCTestCase {
	//swiftlint:disable:next weak_delegate
	private let delegate = CoronaWarnURLSessionDelegate()

	// MARK: - Whitelist testing

	func testWhitelist_HostNotInList() {
		let hostString = "apple.com"
		XCTAssertFalse(delegate.checkWhitelist(for: hostString))
	}

	func testWhitelist_HostNotInListEmptyHost() {
		let hostString = ""
		XCTAssertFalse(delegate.checkWhitelist(for: hostString))
	}

	func testWhitelist_HostInListRegexMatch() {
		let hostString = "svc90int.subdomain.px.t-online.de"
		XCTAssertTrue(delegate.checkWhitelist(for: hostString))
	}

	func testWhitelist_HostInListPerfectMatch() {
		let hostString = "svc90.main.px.t-online.de"
		XCTAssertTrue(delegate.checkWhitelist(for: hostString))
	}

	// MARK: - Public key retrieval testing

	func testPubKeyStoreGetKeyForHost_Exists() {
		let hostString = "coronawarn.app"
		XCTAssertNotNil(delegate.key(for: hostString))
	}

	func testPubKeyStoreGetKeyForHost_DoesNotExist() {
		let hostString = "warn.app"
		XCTAssertNil(delegate.key(for: hostString))
	}
}
