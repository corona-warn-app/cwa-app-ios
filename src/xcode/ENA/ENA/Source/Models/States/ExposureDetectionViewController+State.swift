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

import ExposureNotification
import Foundation
import UIKit

extension ExposureDetectionViewController {
	struct State {
		var exposureManagerState: ExposureManagerState = .init()

		var detectionMode: DetectionMode = DetectionMode.default

		var isTracingEnabled: Bool { exposureManagerState.enabled }
		var isLoading: Bool = false

		var risk: Risk?
		var riskLevel: RiskLevel {
			risk?.level ?? .unknownInitial
		}

		let previousRiskLevel: EitherLowOrIncreasedRiskLevel?

		var actualRiskText: String {
			switch previousRiskLevel {
			case .low:
				return AppStrings.ExposureDetection.low
			case .increased:
				return AppStrings.ExposureDetection.high
			default:
				return AppStrings.ExposureDetection.unknown
			}
		}

		var riskText: String {
			 isTracingEnabled ? riskLevel.text : AppStrings.ExposureDetection.off
		}

		var riskBackgroundColor: UIColor {
			isTracingEnabled ? riskLevel.backgroundColor : .enaColor(for: .background)
		}

		var riskTintColor: UIColor {
			isTracingEnabled ? riskLevel.tintColor : .enaColor(for: .riskNeutral)
		}

		var riskContrastTintColor: UIColor {
			isTracingEnabled ? riskLevel.contrastTintColor : .enaColor(for: .riskNeutral)
		}

		var riskContrastTextColor: UIColor {
			isTracingEnabled ? riskLevel.contrastTextColor : .enaColor(for: .textPrimary1)
		}
	}
}

private extension RiskLevel {
	var text: String {
		switch self {
		case .unknownInitial: return AppStrings.ExposureDetection.unknown
		case .unknownOutdated: return AppStrings.ExposureDetection.unknown
		case .inactive: return AppStrings.ExposureDetection.off
		case .low: return AppStrings.ExposureDetection.low
		case .increased: return AppStrings.ExposureDetection.high
		}
	}

	var backgroundColor: UIColor {
		switch self {
		case .unknownInitial: return .enaColor(for: .riskNeutral)
		case .unknownOutdated: return .enaColor(for: .riskNeutral)
		case .inactive: return .enaColor(for: .background)
		case .low: return .enaColor(for: .riskLow)
		case .increased: return .enaColor(for: .riskHigh)
		}
	}

	var tintColor: UIColor {
		switch self {
		case .unknownInitial: return .enaColor(for: .riskNeutral)
		case .unknownOutdated: return .enaColor(for: .riskNeutral)
		case .inactive: return .enaColor(for: .riskNeutral)
		case .low: return .enaColor(for: .riskLow)
		case .increased: return .enaColor(for: .riskHigh)
		}
	}

	var contrastTintColor: UIColor {
		switch self {
		case .unknownInitial: return .enaColor(for: .textContrast)
		case .unknownOutdated: return .enaColor(for: .textContrast)
		case .inactive: return .enaColor(for: .riskNeutral)
		case .low: return .enaColor(for: .textContrast)
		case .increased: return .enaColor(for: .textContrast)
		}
	}

	var contrastTextColor: UIColor {
		switch self {
		case .unknownInitial: return .enaColor(for: .textContrast)
		case .unknownOutdated: return .enaColor(for: .textContrast)
		case .inactive: return .enaColor(for: .textPrimary1)
		case .low: return .enaColor(for: .textContrast)
		case .increased: return .enaColor(for: .textContrast)
		}
	}
}
