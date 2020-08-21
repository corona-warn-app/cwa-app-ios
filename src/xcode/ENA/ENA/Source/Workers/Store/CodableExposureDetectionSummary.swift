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
import ExposureNotification

struct CodableExposureDetectionSummary: Codable {
	var daysSinceLastExposure: Int
	var matchedKeyCount: UInt64
	let maximumRiskScore: ENRiskScore
	let maximumRiskScoreFullRange: Int
	/// An array that contains the duration, in seconds, at certain attenuations, using an aggregated maximum exposures of 30 minutes.
	///
	/// Its values are adjusted based on the metadata in `ENExposureConfiguration`
	/// - see also: [Apple Documentation](https://developer.apple.com/documentation/exposurenotification/enexposuredetectionsummary/3586324-metadata)
	let configuredAttenuationDurations: [Double]

	init(
		daysSinceLastExposure: Int,
		matchedKeyCount: UInt64,
		maximumRiskScore: ENRiskScore,
		attenuationDurations: [Double],
		maximumRiskScoreFullRange: Int
	) {
		self.daysSinceLastExposure = daysSinceLastExposure
		self.matchedKeyCount = matchedKeyCount
		self.maximumRiskScore = maximumRiskScore
		self.configuredAttenuationDurations = attenuationDurations
		self.maximumRiskScoreFullRange = maximumRiskScoreFullRange
	}

	init?(with summary: ENExposureDetectionSummary?) {
		guard let summary = summary else {
			return nil
		}
		self.init(with: summary)
	}

	init(with summary: ENExposureDetectionSummary) {
		self.daysSinceLastExposure = summary.daysSinceLastExposure
		self.matchedKeyCount = summary.matchedKeyCount
		self.maximumRiskScore = summary.maximumRiskScore
		self.maximumRiskScoreFullRange = (summary.metadata?["maximumRiskScoreFullRange"] as? NSNumber)?.intValue ?? 0
		if let attenuationDurations = summary.metadata?["attenuationDurations"] as? [NSNumber] {
			self.configuredAttenuationDurations = attenuationDurations.map { Double($0.floatValue) }
		} else {
			self.configuredAttenuationDurations = []
		}
	}

	var description: String {
		var str = ""
		str.append("daysSinceLastExposure: \(daysSinceLastExposure)\n")
		str.append("matchedKeyCount: \(matchedKeyCount)\n")
		str.append("maximumRiskScore: \(maximumRiskScore)\n")
		str.append("maximumRiskScoreFullRange: \(maximumRiskScoreFullRange)\n")
		return str
	}
}
