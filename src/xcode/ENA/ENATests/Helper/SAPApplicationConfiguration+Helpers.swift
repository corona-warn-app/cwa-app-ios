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
@testable import ENA

extension SAP_ApplicationConfiguration {

	static var riskCalculationAppConfig: SAP_ApplicationConfiguration {
		makeAppConfig(w_low: 1.0, w_med: 0.5, w_high: 0.5)
	}

	/// Makes an mock `SAP_ApplicationConfiguration`
	///
	/// Some defaults are applied for ad_norm, w4, and low & high ranges
	private static func makeAppConfig(
		ad_norm: Int32 = 25,
		w4: Int32 = 0,
		w_low: Double,
		w_med: Double,
		w_high: Double,
		riskRangeLow: ClosedRange<Int32> = 1...5,
		// Gap between the ranges is on purpose, this is an edge case to test
		riskRangeHigh: Range<Int32> = 6..<11
	) -> SAP_ApplicationConfiguration {
		var config = SAP_ApplicationConfiguration()
		config.attenuationDuration.defaultBucketOffset = w4
		config.attenuationDuration.riskScoreNormalizationDivisor = ad_norm
		config.attenuationDuration.weights.low = w_low
		config.attenuationDuration.weights.mid = w_med
		config.attenuationDuration.weights.high = w_high

		var riskScoreClassLow = SAP_RiskScoreClass()
		riskScoreClassLow.label = "LOW"
		riskScoreClassLow.min = riskRangeLow.lowerBound
		riskScoreClassLow.max = riskRangeLow.upperBound

		var riskScoreClassHigh = SAP_RiskScoreClass()
		riskScoreClassHigh.label = "HIGH"
		riskScoreClassHigh.min = riskRangeHigh.lowerBound
		riskScoreClassHigh.max = riskRangeHigh.upperBound

		config.riskScoreClasses.riskClasses = [
			riskScoreClassLow,
			riskScoreClassHigh
		]

		return config
	}

}
