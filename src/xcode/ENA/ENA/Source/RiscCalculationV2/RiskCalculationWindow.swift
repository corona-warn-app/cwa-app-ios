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

/// Determines the risk level for one exposure window
/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/7779cabcff42afb437f743f1d9e35592ef989c52/docs/spec/exposure-windows.md#determine-risk-level-for-exposure-windows
final class RiskCalculationWindow {

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

	/// 1. Filter by `Minutes at Attenuation`
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

	/// 2. Determine `Transmission Risk Level`
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

	/// 3. Filter by `Transmission Risk Level`
	lazy var isDroppedByTransmissionRiskLevel: Bool = {
		return configuration.trlFilters.map {
			$0.dropIfTrlInRange.contains(transmissionRiskLevel)
		}
		.contains(true)
	}()

	/// 6. Determine `Normalized Time`
	lazy var normalizedTime: Double = {
		return transmissionRiskValue * weightedMinutes
	}()

	/// 7. Determine `Risk Level`
	func riskLevel() throws -> CWARiskLevel {
		guard let riskLevel = configuration.normalizedTimePerEWToRiskLevelMapping
				.first(where: { $0.normalizedTimeRange.contains(normalizedTime) })
				.map({ $0.riskLevel })
		else {
			throw RiskCalculationV2Error.invalidConfiguration
		}

		return riskLevel
	}

	// MARK: - Private

	private let configuration: RiskCalculationConfiguration

	/// 4. Determine `Transmission Risk Value`
	private lazy var transmissionRiskValue: Double = {
		Double(transmissionRiskLevel) * configuration.transmissionRiskLevelMultiplier
	}()

	/// 5. Determine `Weighted Minutes`
	private lazy var weightedMinutes: Double = {
		return exposureWindow.scanInstances.map { scanInstance in
			let weight = configuration.minutesAtAttenuationWeights
				.first { $0.attenuationRange.contains(scanInstance.typicalAttenuation) }
				.map { $0.weight } ?? 0

			return Double(scanInstance.secondsSinceLastScan) * weight
		}.reduce(0, +) / 60
	}()

}
