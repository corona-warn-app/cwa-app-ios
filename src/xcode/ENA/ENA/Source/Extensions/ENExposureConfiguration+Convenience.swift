//
// 🦠 Corona-Warn-App
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
