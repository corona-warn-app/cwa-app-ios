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

import Connectivity
import Foundation

// MARK: - ConnectivityReachabilityService

/// The ConnectivityReachabilityService representing an
/// implementation of the `ConnectivityReachabilityService` protocol
/// and is using the `Connectivity` Swift Package Dependency to allow
/// observing the current `ReachabilityState` (if Internet is available)
final class ConnectivityReachabilityService {
	
	// MARK: Properties
	
	/// The Connectivity instance
	let connectivity: Connectivity
	
	/// The current Connectivity Status
	var connectivityStatus: Connectivity.Status?
	
	/// The Observers listining for ReachabilityState updates
	var observers: [(ReachabilityState) -> Bool]

	private let connectivityURLs: [URL]

	// MARK: Initializer
	
	/// Designated Initializer
	/// - Parameters:
	///   - connectivity: The Connectivity instance. Default value `.init()`
	///   - connectivityStatus: The Connectivity Satus. Default value `nil`
	///   - observers: The Observers listining for ReachabilityState updates. Default value `.init()`
	init(
		connectivity: Connectivity = .init(),
		connectivityURLs: [URL],
		connectivityStatus: Connectivity.Status? = nil,
		observers: [(ReachabilityState) -> Bool] = .init()
	) {
		self.connectivity = connectivity
		self.connectivityStatus = connectivityStatus
		self.connectivityURLs = connectivityURLs
		self.observers = observers
		self.setup()
	}
	
}

// MARK: - Setup

private extension ConnectivityReachabilityService {
	
	/// Perform setup
	func setup() {
		// Set whenConnected closure
		connectivity.whenConnected = { [weak self] in
			// Invoke Connectivity did change
			self?.connectivityDidChange(to: $0.status)
		}
		// Set whenDisconnected closure
		connectivity.whenDisconnected = { [weak self] in
			// Invoke Connectivity did change
			self?.connectivityDidChange(to: $0.status)
		}
		// Enable Polling when running in the simulator
		// Read more: https://github.com/rwbutler/Connectivity#simulator-issues
		#if targetEnvironment(simulator)
		connectivity.isPollingEnabled = true
		#endif

		connectivity.connectivityURLs = connectivityURLs
		connectivity.responseValidator = CustomConnectivityResponseValidator()
		connectivity.validationMode = .custom

		// Start Notifier
		connectivity.startNotifier()
	}
	
}

// MARK: - Connectivity did change

private extension ConnectivityReachabilityService {
	
	/// Connectivity did change
	/// - Parameter status: The Connectivity Status
	func connectivityDidChange(to status: Connectivity.Status) {
		// Update current Connectivity Status
		self.connectivityStatus = status
		// Initialize ReachabilityState from Connectivity Status
		let reachabilityState = ReachabilityState(status)
		// Re-Initialize Observer by invoking each Observer and filter
		// out those which are no longer available
		self.observers = self.observers.filter { $0(reachabilityState) }
	}
	
}

// MARK: - ReachabilityService

extension ConnectivityReachabilityService: ReachabilityService {
	
	/// Observe ReachabilityState
	/// - Parameters:
	///   - object: The Object to observe on
	///   - observer: The Observer closure
	func observe<Object: AnyObject>(
		on object: Object,
		observer: @escaping (ReachabilityState) -> Void
	) {
		// Flat map current Connectivity.Status to ReachabilityState
		// and invoke Observer
		self.connectivityStatus
			.flatMap(ReachabilityState.init)
			.flatMap(observer)
		// Append Observer closure by keeping only a weak reference to object
		self.observers.append { [weak object] reachabilityState in
			// Verify weak referenced Object is available
			guard object != nil else {
				// Otherwise return false as object is no longer available
				return false
			}
			// Invoke observer with the given ReachabilityState
			observer(reachabilityState)
			// Return true as the object is still available
			return true
		}
	}
	
}

// MARK: - ReachabilityState+Connectivity.Status

private extension ReachabilityState {
	
	/// Initializer with Connectivity Status
	/// - Parameter connectivityStatus: The Connectivity Status
	init(_ connectivityStatus: Connectivity.Status) {
		// Switch on Connectivity Status
		switch connectivityStatus {
		case .connected,
			 .connectedViaCellular,
			 .connectedViaWiFi:
			// Initialize with connected as the device
			// is either connected via celluar or wifi
			self = .connected
		case .notConnected,
			 .connectedViaCellularWithoutInternet,
			 .connectedViaWiFiWithoutInternet,
			 .determining:
			// Initialize with disconnected as there is
			// no valid internet connection available
			self = .disconnected
		}
	}
	
}

final class CustomConnectivityResponseValidator: ConnectivityResponseValidator {
	func isResponseValid(url: URL, response: URLResponse?, data: Data?) -> Bool {
		response != nil
	}
}
