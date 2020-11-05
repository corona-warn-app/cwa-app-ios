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
@testable import ENA

extension ENCalibrationConfidence: Codable { }
extension ENDiagnosisReportType: Codable { }
extension ENInfectiousness: Codable { }

extension ENA.ExposureWindow: Decodable {

	// MARK: - Init

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let calibrationConfidence = try container.decode(ENCalibrationConfidence.self, forKey: .calibrationConfidence)
		let reportType = try container.decode(ENDiagnosisReportType.self, forKey: .reportType)
		let infectiousness = try container.decode(ENInfectiousness.self, forKey: .infectiousness)
		let scanInstances = try container.decode([ScanInstance].self, forKey: .scanInstances)

		let ageInDays = try container.decode(Int.self, forKey: .date)
		guard let date = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Calendar.current.startOfDay(for: Date())) else {
			fatalError("Date could not be generated")
		}

		self.init(calibrationConfidence: calibrationConfidence, date: date, reportType: reportType, infectiousness: infectiousness, scanInstances: scanInstances)
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {

		case calibrationConfidence, reportType, infectiousness, scanInstances
		case date = "ageInDays"

	}

}
