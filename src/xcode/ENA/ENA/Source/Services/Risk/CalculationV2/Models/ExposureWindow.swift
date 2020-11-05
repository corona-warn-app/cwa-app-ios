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

struct ExposureWindow {

	// MARK: - Init

	init(
		calibrationConfidence: ENCalibrationConfidence,
		date: Date,
		reportType: ENDiagnosisReportType,
		infectiousness: ENInfectiousness,
		scanInstances: [ScanInstance]
	) {
		self.calibrationConfidence = calibrationConfidence
		self.date = date
		self.reportType = reportType
		self.infectiousness = infectiousness
		self.scanInstances = scanInstances
	}

	init(from exposureWindow: ENExposureWindow) {
		self.calibrationConfidence = exposureWindow.calibrationConfidence
		self.date = exposureWindow.date
		self.reportType = exposureWindow.diagnosisReportType
		self.infectiousness = exposureWindow.infectiousness
		self.scanInstances = exposureWindow.scanInstances.map { ScanInstance(from: $0) }
	}

	// MARK: - Internal

	let calibrationConfidence: ENCalibrationConfidence
	let date: Date
	let reportType: ENDiagnosisReportType
	let infectiousness: ENInfectiousness
	let scanInstances: [ScanInstance]

}
