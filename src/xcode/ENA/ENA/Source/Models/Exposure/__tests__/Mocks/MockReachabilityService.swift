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

@testable import ENA
import Foundation

// MARK: - MockReachabilityService

/// A mocked / faked ReachabilityService implementation
final class MockReachabilityService {
	
	// MARK: Properties
	
	/// The current ReachabilityState. A `didSet` event will invoke all observer
	var reachabilityState: ReachabilityState? {
		didSet {
			// Verify ReachabilityState is available
			guard let reachabilityState = self.reachabilityState else {
				// Otherwise return out of function
				return
			}
			// Invoke each Observer with the updated ReachabilityState
			self.observers.forEach { $0(reachabilityState) }
		}
	}
	
	/// The Observers
	var observers: [(ReachabilityState) -> Void]
	
	// MARK: Initializer
	
	/// Designated Initializer
	/// - Parameters:
	///   - reachabilityState: The current ReachabilityState. Default value `nil`
	///   - observers: The Observers. Default value `.init()`
	init(
		reachabilityState: ReachabilityState? = nil,
		observers: [(ReachabilityState) -> Void] = .init()
	) {
		self.reachabilityState = reachabilityState
		self.observers = observers
	}
	
}

// MARK: - ReachabilityService

extension MockReachabilityService: ReachabilityService {
	
	/// Observe ReachabilityState
	/// - Parameters:
	///   - object: The Object to observe on
	///   - observer: The Observer closure
	func observe<Object: AnyObject>(
		on object: Object,
		observer: @escaping (ReachabilityState) -> Void
	) {
		// Invoke observer if a ReachabilityState is available
		self.reachabilityState.flatMap(observer)
		// Append Observer
		self.observers.append(observer)
	}
	
}
