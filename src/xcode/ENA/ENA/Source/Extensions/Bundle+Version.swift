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

extension Bundle {

	var appVersion: String {
		guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
			fatalError("Could not read CFBundleShortVersionString from Bundle.")
		}
		return version
	}

	var appBuildNumber: String {
		guard let buildNumber = infoDictionary?[kCFBundleVersionKey as String] as? String else {
			fatalError("Could not read CFBundleVersion from Bundle.")
		}
		return buildNumber
	}
}
