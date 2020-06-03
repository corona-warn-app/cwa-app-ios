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

// MARK: - ReachabilityState

/// The ReachabilityState representing the current state of reachability
/// in terms of if a valid internet connection is available or not
enum ReachabilityState {
	/// Connected. A valid internet connection is available
	case connected
	/// Disconnected. No valid internet connection is available
	case disconnected
}

// MARK: - ReachabilityService

/// The ReachabilityService used to observe the ReachabilityState
/// in order to determine if a Internet connection is available or not
protocol ReachabilityService {
	
	/// Observe ReachabilityState
	/// - Parameters:
	///   - object: The Object to observe on
	///   - observer: The Observer closure
	func observe<Object: AnyObject>(
		on object: Object,
		observer: @escaping (ReachabilityState) -> Void
	)
	
}
