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
import ExposureNotification

protocol ENStateHandlerUpdating: AnyObject {
	func updateEnState(_ state: ENStateHandler.State)
}


final class ENStateHandler {

	private var currentState: State! {
		didSet {
			stateDidChange()
		}
	}

	var state: ENStateHandler.State {
		currentState
	}

	private weak var delegate: ENStateHandlerUpdating?
	private var latestExposureManagerState: ExposureManagerState
	
	init(
		initialExposureManagerState: ExposureManagerState,
		delegate: ENStateHandlerUpdating
	) {
		self.delegate = delegate
		self.latestExposureManagerState = initialExposureManagerState
		self.currentState = determineCurrentState(from: latestExposureManagerState)
	}

	private func stateDidChange() {
		guard let delegate = delegate else {
			fatalError("Delegate is nil. It should not happen.")
		}
		delegate.updateEnState(currentState)
	}

	private func determineCurrentState(from enManagerState: ExposureManagerState) -> State {

		switch enManagerState.status {
		case .active:
			return .enabled
		case .bluetoothOff:
			guard !enManagerState.enabled == false else {
				return .disabled
			}
			return .bluetoothOff
		case .disabled:
			return .disabled
		case .restricted:
			return differentiateRestrictedCase()
		case .unknown:
			return .disabled
		@unknown default:
			fatalError("New state was added that is not being covered by ENStateHandler")
		}
	}

	private func differentiateRestrictedCase() -> State {
		switch ENManager.authorizationStatus {
		case .notAuthorized:
			return .notAuthorized
		case .restricted:
			return .restricted
		case .unknown:
			return .unknown
		case .authorized:
			return .disabled
		@unknown default:
			fatalError("New state was added that is not being covered by ENStateHandler")
		}
	}
}

extension ENStateHandler: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		latestExposureManagerState = state
		currentState = determineCurrentState(from: state)
	}
}
