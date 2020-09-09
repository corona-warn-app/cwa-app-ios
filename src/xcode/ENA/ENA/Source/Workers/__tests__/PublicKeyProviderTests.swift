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
import CryptoKit
@testable import ENA

extension StaticString: Equatable {
	public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
		// swiftlint:disable:next identical_operands
		return "\(lhs)" == "\(rhs)"
	}
}

final class PublicKeyProviderTests: XCTestCase {
	func testThatKeysHaveNotBeenAlteredAccidentally() {
		XCTAssertEqual(
			PublicKeyEnv.production.stringRepresentation,
			"c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
		)
		XCTAssertEqual(
			PublicKeyEnv.development.stringRepresentation,
			"3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q=="
		)
	}
	
	// There was a bug in our code that converted the string rep. of the key to plain unicode instead of base64 encoded data.
	func testDefaultPublicKeyFromString() throws {
		let pk: StaticString = "c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
		let data = try XCTUnwrap(Data(staticBase64Encoded: pk))
		XCTAssertEqual(
			try DefaultPublicKeyFromString(pk)().rawRepresentation,
			try P256.Signing.PublicKey(rawRepresentation: data).rawRepresentation
		)
	}
}
