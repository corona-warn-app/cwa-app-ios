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

private func _withPrefix(_ name: String) -> Notification.Name {
	Notification.Name("com.sap.ena.\(name)")
}

extension Notification.Name {
	static let isOnboardedDidChange = _withPrefix("isOnboardedDidChange")

	// Temporary Notification until implemented by actual transaction flow
	static let didDetectExposureDetectionSummary = _withPrefix("didDetectExposureDetectionSummary")
}
