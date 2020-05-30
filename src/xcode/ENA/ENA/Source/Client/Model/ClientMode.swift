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

import Foundation

/// Describes the mode of operation used by the app when talking to the backend.
///
/// The app has two main modes of operation:
///
/// 1. `mock`: In this mode the app talks to a 100% mocked backend that does not even require an HTTP connection.
/// 2. `https`: In this mode the app us using an `URLSession` to talk to the backend.
///
/// As a developer you can override the client mode by setting the environment variable `CWA_CLIENT_MODE` either to `mock` or `https`. In `APP_STORE` builds this feature is disabled.
enum ClientMode: String {
	case mock
	case https

	static func from(environment _: [String: String]) -> ClientMode {
		// We disable mocking
		.https
		//        #if APP_STORE
		//        return .https
		//        #endif
		//        let defaultMode = ClientMode.https
		//        let value = environment["CWA_CLIENT_MODE"] ?? defaultMode.rawValue
		//        return ClientMode(rawValue: value) ?? defaultMode
	}

	static func from(processInfo: ProcessInfo) -> ClientMode {
		from(environment: processInfo.environment)
	}

	static let `default` = ClientMode.from(processInfo: .processInfo)
}
