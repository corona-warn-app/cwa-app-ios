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

extension ENExposureConfiguration {

	convenience init(from exposureConfiguration: SAP_Internal_V2_ExposureConfiguration) {
		self.init()

		var dict = [NSNumber: NSNumber]()
		for (key, value) in exposureConfiguration.infectiousnessForDaysSinceOnsetOfSymptoms {
			dict[NSNumber(value: key)] = NSNumber(value: value)
		}
		infectiousnessForDaysSinceOnsetOfSymptoms = dict

		reportTypeNoneMap = ENDiagnosisReportType(rawValue: ENDiagnosisReportType.RawValue(exposureConfiguration.reportTypeNoneMap)) ?? .unknown
		attenuationDurationThresholds = exposureConfiguration.attenuationDurationThresholds.map { NSNumber(value: $0) }
		immediateDurationWeight = exposureConfiguration.immediateDurationWeight
		mediumDurationWeight = exposureConfiguration.mediumDurationWeight
		nearDurationWeight = exposureConfiguration.nearDurationWeight
		otherDurationWeight = exposureConfiguration.otherDurationWeight
		daysSinceLastExposureThreshold = Int(exposureConfiguration.daysSinceLastExposureThreshold)
		infectiousnessStandardWeight = exposureConfiguration.infectiousnessStandardWeight
		infectiousnessHighWeight = exposureConfiguration.infectiousnessHighWeight
		reportTypeConfirmedTestWeight = exposureConfiguration.reportTypeConfirmedTestWeight
		reportTypeConfirmedClinicalDiagnosisWeight = exposureConfiguration.reportTypeConfirmedClinicalDiagnosisWeight
		reportTypeSelfReportedWeight = exposureConfiguration.reportTypeSelfReportedWeight
		reportTypeRecursiveWeight = exposureConfiguration.reportTypeRecursiveWeight
	}

}
