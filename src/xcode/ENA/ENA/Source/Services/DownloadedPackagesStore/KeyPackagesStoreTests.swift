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

final class DownloadedPackagesStoreTests: XCTestCase {
	func testMissingDays_EmptyStore() {
		let store = DownloadedPackagesInMemoryStore()
		XCTAssertEqual(store.missingDays(remoteDays: []), [])
		XCTAssertEqual(store.missingDays(remoteDays: ["a"]), ["a"])
		XCTAssertEqual(store.missingDays(remoteDays: ["a", "b"]), ["a", "b"])
	}
	
	func testMissingDays_FilledStore() {
		let store = DownloadedPackagesInMemoryStore()
		
		store.set(
			day: "a",
			package:
			SAPDownloadedPackage(
				keysBin: Data(bytes: [0xA], count: 1),
				signature: Data(bytes: [0xA], count: 1)
			)
		)
		
		XCTAssertEqual(store.missingDays(remoteDays: []), [])
		// we already have "a"
		XCTAssertEqual(store.missingDays(remoteDays: ["a"]), [])
		
		// we are missing "b"
		XCTAssertEqual(store.missingDays(remoteDays: ["a", "b"]), ["b"])
		
		store.set(
			day: "b",
			package:
			SAPDownloadedPackage(
				keysBin: Data(bytes: [0xA], count: 1),
				signature: Data(bytes: [0xB], count: 1)
			)
		)
		
		// we are not missing anything
		XCTAssertEqual(store.missingDays(remoteDays: ["a", "b"]), [])
		
		// we are missing c
		XCTAssertEqual(store.missingDays(remoteDays: ["a", "b", "c"]), ["c"])
	}
	
	func testMissingHours_EmptyStore() {
		let store = DownloadedPackagesInMemoryStore()
		XCTAssertEqual(
			store.missingHours(day: "a", remoteHours: []),
			[]
		)
		XCTAssertEqual(
			store.missingHours(day: "a", remoteHours: [1, 2, 3, 4]),
			[1, 2, 3, 4]
		)
	}
	
	func testMissingHours_StoreWithDaysButNoRemoteHours() {
		let store = DownloadedPackagesInMemoryStore()
		store.set(
			day: "a",
			package: SAPDownloadedPackage(
				keysBin: Data(bytes: [0xA], count: 1),
				signature: Data(bytes: [0xB], count: 1)
			)
		)
		
		XCTAssertEqual(
			store.missingHours(day: "a", remoteHours: []),
			[]
		)
	}
	
	func testMissingHours_StoreWithDaysAndHours() {
		let store = DownloadedPackagesInMemoryStore()
		store.set(
			day: "a",
			package: SAPDownloadedPackage(
				keysBin: Data(bytes: [0xA], count: 1),
				signature: Data(bytes: [0xB], count: 1)
			)
		)
		
		XCTAssertEqual(
			store.missingHours(day: "a", remoteHours: []),
			[]
		)
		XCTAssertEqual(
			store.missingHours(day: "b", remoteHours: []),
			[]
		)
		XCTAssertEqual(
			store.missingHours(day: "b", remoteHours: [1, 2, 3, 4]),
			[1, 2, 3, 4]
		)
		
		store.set(
			hour: 1,
			day: "b",
			package:
			SAPDownloadedPackage(
				keysBin: Data(bytes: [0xA], count: 1),
				signature: Data(bytes: [0xB], count: 1)
			)
		)
		XCTAssertEqual(
			store.missingHours(day: "b", remoteHours: [1, 2, 3, 4]),
			[2, 3, 4]
		)
		
		store.set(
			hour: 4,
			day: "b",
			package: SAPDownloadedPackage(
				keysBin: Data(bytes: [0xA], count: 1),
				signature: Data(bytes: [0xB], count: 1)
			)
		)
		XCTAssertEqual(
			store.missingHours(day: "b", remoteHours: [1, 2, 3, 4]),
			[2, 3]
		)
	}
}
