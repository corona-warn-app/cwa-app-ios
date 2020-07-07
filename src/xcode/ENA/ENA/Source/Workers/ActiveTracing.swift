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

import Foundation

private extension TimeInterval {
	static let SEC_PER_HOUR: TimeInterval = 3600.0
	static let SEC_PER_DAY = SEC_PER_HOUR * 24.0
}

struct ActiveTracing {
	let interval: TimeInterval
	let maximumNumberOfDays: Int

	init(interval: TimeInterval, maximumNumberOfDays: Int) {
		self.interval = interval
		self.maximumNumberOfDays = maximumNumberOfDays
	}

	var inHours: Int {
		// Hours are intentionally rounded down.
		// We could also simply cast this to `Int` (what we actually do here as well)
		// but we still call rounded(…) to make it more explicit.
		Int((interval / TimeInterval.SEC_PER_HOUR).rounded(.down))
	}
	
	var inDays: Int {
		Int((interval / TimeInterval.SEC_PER_DAY).rounded(.toNearestOrAwayFromZero))
	}
}
