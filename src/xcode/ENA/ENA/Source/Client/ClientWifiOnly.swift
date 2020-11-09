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

import ExposureNotification
import Foundation

protocol ClientWifiOnly {

	typealias HourCompletionHandler = (Result<SAPDownloadedPackage, Client.Failure>) -> Void

	/// Fetches the keys for a given `hour` of a specific `day`.
	func fetchHour(
		_ hour: Int,
		day: String,
		country: String,
		completion: @escaping HourCompletionHandler
	)

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping (HoursResult) -> Void
	)

}
