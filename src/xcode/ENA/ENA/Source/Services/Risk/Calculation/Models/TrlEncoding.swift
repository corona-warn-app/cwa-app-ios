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

struct TrlEncoding: Codable {

	// MARK: - Init

	init(from trlEncoding: SAP_Internal_V2_TransmissionRiskLevelEncoding) {
		self.infectiousnessOffsetStandard = Int(trlEncoding.infectiousnessOffsetStandard)
		self.infectiousnessOffsetHigh = Int(trlEncoding.infectiousnessOffsetHigh)
		self.reportTypeOffsetRecursive = Int(trlEncoding.reportTypeOffsetRecursive)
		self.reportTypeOffsetSelfReport = Int(trlEncoding.reportTypeOffsetSelfReport)
		self.reportTypeOffsetConfirmedClinicalDiagnosis = Int(trlEncoding.reportTypeOffsetConfirmedClinicalDiagnosis)
		self.reportTypeOffsetConfirmedTest = Int(trlEncoding.reportTypeOffsetConfirmedTest)
	}

	// MARK: - Internal

	let infectiousnessOffsetStandard: Int
	let infectiousnessOffsetHigh: Int
	let reportTypeOffsetRecursive: Int
	let reportTypeOffsetSelfReport: Int
	let reportTypeOffsetConfirmedClinicalDiagnosis: Int
	let reportTypeOffsetConfirmedTest: Int
	
}
