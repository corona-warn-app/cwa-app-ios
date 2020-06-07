//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

import Foundation

protocol RiskProviding: AnyObject {
	typealias Completion = (Result<Risk, Error>) -> Void

	func observeRisk(_ consumer: RiskConsumer)
	func requestRisk(userInitiated: Bool)

	var configuration: RiskProvidingConfiguration { get set }
	func nextExposureDetectionDate() -> Date
}

enum ManualExposureDetectionState {
	case possible
	case waiting
}

final class RiskConsumer: NSObject {
	// MARK: Creating a Consumer
	init(targetQueue: DispatchQueue = .main) {
		self.targetQueue = targetQueue
	}

	// MARK: Properties
	let targetQueue: DispatchQueue

	/// Called when the risk level changed
	var didCalculateRisk: ((Risk) -> Void)?

	/// Called when the risk level changed
	var manualExposureDetectionStateDidChange: ((ManualExposureDetectionState) -> Void)?

	/// Called when the date of the next exposure detection changed
	var nextExposureDetectionDateDidChange: ((Date) -> Void)?
}
