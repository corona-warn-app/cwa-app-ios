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

extension CodableExposureDetectionSummary {

	static var summaryLow: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 80, ad_low: 10, ad_mid: 10, ad_high: 10)
	}

	static var summaryMed: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 128, ad_low: 15, ad_mid: 15, ad_high: 15)
	}

	static var summaryHigh: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 255, ad_low: 30, ad_mid: 30, ad_high: 30)
	}

	static func summary(for riskLevel: EitherLowOrIncreasedRiskLevel) -> CodableExposureDetectionSummary {
		switch riskLevel {
		case .low:
			return .summaryLow
		case .increased:
			return .summaryHigh
		}
	}

	static func makeExposureSummaryContainer(
		maxRiskScoreFullRange: Int,
		ad_low: Double,
		ad_mid: Double,
		ad_high: Double
	) -> CodableExposureDetectionSummary {
		.init(
			daysSinceLastExposure: 0,
			matchedKeyCount: 0,
			maximumRiskScore: 0,
			attenuationDurations: [ad_low, ad_mid, ad_high],
			maximumRiskScoreFullRange: maxRiskScoreFullRange
		)
	}

}
