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

extension ENCalibrationConfidence: Codable { }
extension ENDiagnosisReportType: Codable { }
extension ENInfectiousness: Codable { }

struct ExposureWindow: Decodable {

	// MARK: - Init

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		calibrationConfidence = try container.decode(ENCalibrationConfidence.self, forKey: .calibrationConfidence)
		reportType = try container.decode(ENDiagnosisReportType.self, forKey: .reportType)
		infectiousness = try container.decode(ENInfectiousness.self, forKey: .infectiousness)
		scanInstances = try container.decode([ScanInstance].self, forKey: .scanInstances)

		let ageInDays = try container.decode(Int.self, forKey: .date)
		guard let date = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Calendar.current.startOfDay(for: Date())) else {
			fatalError("Date could not be generated")
		}

		self.date = date
	}

	init(from exposureWindow: ENExposureWindow) {
		self.calibrationConfidence = exposureWindow.calibrationConfidence
		self.date = exposureWindow.date
		self.reportType = exposureWindow.diagnosisReportType
		self.infectiousness = exposureWindow.infectiousness
		self.scanInstances = exposureWindow.scanInstances.map { ScanInstance(from: $0) }
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {

		case calibrationConfidence, reportType, infectiousness, scanInstances
		case date = "ageInDays"

	}

	// MARK: - Internal

	let calibrationConfidence: ENCalibrationConfidence
	let date: Date
	let reportType: ENDiagnosisReportType
	let infectiousness: ENInfectiousness
	let scanInstances: [ScanInstance]

}
