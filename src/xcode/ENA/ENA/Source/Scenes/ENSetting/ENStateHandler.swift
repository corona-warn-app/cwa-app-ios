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



protocol StateHandlerObserverDelegate: AnyObject {
	func stateDidChange(to state:  ENStateHandler.State)
	func getLatestExposureManagerState() -> ExposureManagerState
}

final class ENStateHandler {

	enum State {
		/// Exposure Notification is enabled.
		case enabled
		/// Exposure Notification is disabled.
		case disabled
		/// Bluetooth is off.
		case bluetoothOff
		/// Internet is off.
		case internetOff
		/// Restricted Mode.
		case restricted
	}

	private var currentState: State! {
		didSet {
			stateDidChange()
		}
	}
	
	private let reachabilityService: ReachabilityService
	private weak var delegate: StateHandlerObserverDelegate?
	private var internetOff = false

	init(
		_ initialState: ExposureManagerState,
		reachabilityService: ReachabilityService,
		delegate: StateHandlerObserverDelegate
	) {
		self.reachabilityService = reachabilityService
		self.delegate = delegate
		currentState = determineCurrentState(from: initialState)
		self.reachabilityService.observe(on: self) { [weak self] reachabilityState in
			self?.internet(reachabilityState == .connected)
		}
	}

	private func internet(_ isReachable: Bool) {
		if !isReachable {
			internetOff = true
		} else {
			internetOff = false
		}

		switch currentState {
		case .disabled, .bluetoothOff, .restricted:
			return
		case .enabled:
			if !isReachable {
				currentState = .internetOff
			}
		case .internetOff:
			guard let latestState = delegate?.getLatestExposureManagerState() else {
				return
			}
			currentState = determineCurrentState(from: latestState)
		case .none:
			fatalError("Unexpected state found in ENState Handler")
		}
	}

	private func stateDidChange() {
		delegate?.stateDidChange(to: currentState)
	}

	private func determineCurrentState(from enManagerState: ExposureManagerState) -> State {

		switch enManagerState.status {
		case .active:
			guard !internetOff else {
				return .internetOff
			}
			return .enabled
		case .bluetoothOff:
			guard !enManagerState.enabled == false else {
				return .disabled
			}
			return .bluetoothOff
		case .disabled:
			return .disabled
		case .restricted:
			return .restricted
		case .unknown:
			return .disabled
		@unknown default:
			fatalError("New state was added that is not being covered by ENStateHandler")
		}
	}

	func getState() -> State {
		currentState
	}

	func exposureManagerDidUpdate(to state: ExposureManagerState) {
		currentState = determineCurrentState(from: state)
	}
}
