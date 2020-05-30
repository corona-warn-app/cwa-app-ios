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
	enum RefreshMode {
		case automatic
		case manual
	}

	struct State {
		var exposureManagerState: ExposureManagerState = .init()

		var mode: RefreshMode = .manual

		var isTracingEnabled: Bool { exposureManagerState.enabled }
		var isLoading: Bool = false

		var riskLevel: RiskLevel = .unknown
		var nextRefresh: Date?
		var summary: ExposureDetectionViewController.Summary?

		var actualRiskText: String {
			riskLevel.text
		}

		var riskText: String {
			isTracingEnabled ? riskLevel.text : AppStrings.ExposureDetection.off
		}

		var riskTintColor: UIColor {
			isTracingEnabled ? riskLevel.tintColor : .preferredColor(for: .backgroundPrimary)
		}

		var riskContrastColor: UIColor {
			isTracingEnabled ? riskLevel.contrastColor : .preferredColor(for: .textPrimary1)
		}
	}
}

private extension RiskLevel {
	var text: String {
		switch self {
		case .unknown: return AppStrings.ExposureDetection.unknown
		case .inactive: return AppStrings.ExposureDetection.inactive
		case .low: return AppStrings.ExposureDetection.low
		case .high: return AppStrings.ExposureDetection.high
		}
	}

	var tintColor: UIColor {
		switch self {
		case .unknown: return .preferredColor(for: .unknownRisk)
		case .inactive: return .preferredColor(for: .inactiveRisk)
		case .low: return .preferredColor(for: .positiveRisk)
		case .high: return .preferredColor(for: .negativeRisk)
		}
	}

	var contrastColor: UIColor {
		switch self {
		case .unknown: return .white
		case .inactive: return .white
		case .low: return .white
		case .high: return .white
		}
	}
}
