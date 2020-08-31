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

/// Exposure Risk level
enum RiskLevel: Int, CaseIterable, Equatable {
	/*
	Generally, the risk level hiearchy is as the raw values in the enum cases state. .low is lowest and .inactive highest.
	The risk calculation itself takes multiple parameters into account, for example how long tracing has been active for,
	and the date of the last exposure detection.
	
	There is one special situation where the hierarchy defined below is not followed. Assume:
	- Last exposure detection is more than 48 hours old -> .unknownOutdated applies
	- Summary & AppConfig resolve to .increased risk
	- Tracing has been active for more than 24 hours
	
	According to the hierarchy we should return .increased risk. In this case however .unknownOutdated should be returned!
	*/
	
	/// Low risk
	case low = 0
	/// Unknown risk  last calculation more than 24 hours old
	///
	/// Will be shown when the last calculation is more than 24 hours old - until the calculation is run again
	case unknownOutdated
	/// Unknown risk - no calculation has been performed yet or tracing has been active for less than 24h
	case unknownInitial
	/// Increased risk
	case increased
	/// No calculation possible - tracing is inactive
	///
	/// - important: Should always be displayed, even if a different risk level has been calculated. It overrides all other levels!
	case inactive
}

extension RiskLevel: Comparable {
	static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}
