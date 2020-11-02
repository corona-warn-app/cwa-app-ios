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

class RiskCalculationWindow {

	// MARK: - Init

	init(
		exposureWindow: ExposureWindow,
		configuration: RiskCalculationConfiguration
	) {
		self.exposureWindow = exposureWindow
		self.configuration = configuration
	}

	// MARK: - Internal

	let exposureWindow: ExposureWindow

	/// Risk calculation based on exposure windows:
	/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/512a4fd598179a98b32a73d9d86e6e536e67f7f8/docs/spec/exposure-windows.md#aggregate-results-from-exposure-windows

	func riskLevel() throws -> CWARiskLevel {
		let riskLevel = configuration.normalizedTimePerEWToRiskLevelMapping
			.first { $0.normalizedTimeRange.contains(normalizedTime) }
			.map { $0.riskLevel }

		guard let unwrappedRiskLevel = riskLevel else {
			throw RiskCalculationV2Error.invalidConfiguration
		}

		return unwrappedRiskLevel
	}

	lazy var isDroppedByMinutesAtAttenuation: Bool = {
		return configuration.minutesAtAttenuationFilters.map { filter in
			let secondsAtAttenuation = exposureWindow.scanInstances
				.filter { scanInstance in
					filter.attenuationRange.contains(scanInstance.typicalAttenuation)
				}
				.map { $0.secondsSinceLastScan }
				.reduce(0, +)

			let minutesAtAttenuation = secondsAtAttenuation / 60

			return filter.dropIfMinutesInRange.contains(minutesAtAttenuation)
		}
		.contains(true)
	}()

	lazy var isDroppedByTransmissionRiskLevel: Bool = {
		return configuration.trlFilters.map {
			$0.dropIfTrlInRange.contains(transmissionRiskLevel)
		}
		.contains(true)
	}()

	lazy var normalizedTime: Double = {
		return transmissionRiskValue * weightedMinutes
	}()

	lazy var transmissionRiskLevel: Int = {
		let infectiousnessOffset = exposureWindow.infectiousness == .high ?
			configuration.trlEncoding.infectiousnessOffsetHigh :
			configuration.trlEncoding.infectiousnessOffsetStandard

		var reportTypeOffset: Int
		switch exposureWindow.reportType {
		case .confirmedTest:
			reportTypeOffset = configuration.trlEncoding.reportTypeOffsetConfirmedTest
		case .confirmedClinicalDiagnosis:
			reportTypeOffset = configuration.trlEncoding.reportTypeOffsetConfirmedClinicalDiagnosis
		case .selfReported:
			reportTypeOffset = configuration.trlEncoding.reportTypeOffsetSelfReport
		case .recursive:
			reportTypeOffset = configuration.trlEncoding.reportTypeOffsetRecursive
		default:
			reportTypeOffset = 0
		}

		return infectiousnessOffset + reportTypeOffset
	}()

	// MARK: - Private

	private let configuration: RiskCalculationConfiguration

	private lazy var transmissionRiskValue: Double = {
		Double(transmissionRiskLevel) * configuration.transmissionRiskLevelMultiplier
	}()

	private lazy var weightedMinutes: Double = {
		return exposureWindow.scanInstances.map { scanInstance in
			let weight = configuration.minutesAtAttenuationWeights
				.first { $0.attenuationRange.contains(scanInstance.typicalAttenuation) }
				.map { $0.weight } ?? 0

			return Double(scanInstance.secondsSinceLastScan) * weight
		}.reduce(0, +) / 60
	}()

}
