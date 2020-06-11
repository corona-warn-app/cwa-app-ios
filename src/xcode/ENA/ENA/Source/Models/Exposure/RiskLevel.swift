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
///
/// - important: Due to exception case, `CaseIterable` `allCases` does not produce a correctly sorted collection!
enum RiskLevel: Int, CaseIterable {
	/*
	RiskLevels are ordered according to these rules:
	1. .low is least
	2. .inactive is highest
	3. .increased overrides .unknownOutdated
	4. .unknownOutdated overrides .low AND .increased
	5. .unknownInitial overrides .low AND .unknownOutdated
	*/
	
	/// Low risk
	case low = 0
	/// Increased risk
	///
	/// - important: Should overrule `.unknownOutdated`, and `.unknownInitial`
	case increased
	/// Unknown risk  last calculation more than 24 hours old
	///
	/// Will be shown when the last calculation is more than 24 hours old - until the calculation is run again
	/// - important: Overrules `.increased` and `low`
	case unknownOutdated
	/// Unknown risk - no calculation has been performed yet
	///
	/// - important: Overrules `.low` and `.unknownOutdated`
	case unknownInitial
	/// No calculation possible - tracing is inactive
	///
	/// - important: Should always be displayed, even if a different risk level has been calculated. It should override all other levels!
	case inactive
}

extension RiskLevel: Comparable {
	/// - attention: Might not produce valid results when sorting Collections  of RiskLevels, because of the exception case which overrides the normal rawValue compare!
	static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
		// Generally we compare the raw values, but there is one exception:
		// .increased should override .unknownOutdated
		switch (lhs, rhs) {
		case (.unknownOutdated, .increased):
			return true
		// .increased should override .unknownInitial
		case (.unknownInitial, .increased):
				return true
		default:
		return lhs.rawValue < rhs.rawValue
		}
	}
}
