//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

/// Used to configure a `RiskLevelProvider`.
struct RiskProvidingConfiguration {
	/// The duration a conducted exposure detection is considered valid.
	var exposureDetectionValidityDuration: DateComponents

	/// Time interval between exposure detections.
	var exposureDetectionInterval: DateComponents

	/// The mode of operation
	var detectionMode: DetectionMode = DetectionMode.default
}

extension RiskProvidingConfiguration {
	func exposureDetectionValidUntil(lastExposureDetectionDate: Date?) -> Date {
		Calendar.current.date(
			byAdding: exposureDetectionValidityDuration,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
			) ?? .distantPast
	}

	func nextExposureDetectionDate(lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> Date {
		let potentialDate = Calendar.current.date(
			byAdding: exposureDetectionInterval,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
			) ?? .distantPast
		return potentialDate > currentDate ? currentDate : potentialDate
	}

	func exposureDetectionIsValid(lastExposureDetectionDate: Date = .distantPast, currentDate: Date = Date()) -> Bool {
		// It is not valid to have a future exposure detection date
		guard lastExposureDetectionDate <= currentDate else { return false }

		return currentDate < exposureDetectionValidUntil(lastExposureDetectionDate: lastExposureDetectionDate)
	}

	func shouldPerformExposureDetection(lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> Bool {
		if let lastExposureDetectionDate = lastExposureDetectionDate, lastExposureDetectionDate > currentDate {
			// It is not valid to have a future exposure detection date.
			return true
		}
		let next = nextExposureDetectionDate(lastExposureDetectionDate: lastExposureDetectionDate, currentDate: currentDate)
		let result = next < currentDate
		return result
	}

	func manualExposureDetectionState(lastExposureDetectionDate detectionDate: Date?) -> ManualExposureDetectionState? {
		guard detectionMode != .automatic else {
			return nil
		}
		return shouldPerformExposureDetection(lastExposureDetectionDate: detectionDate) ? .possible : .waiting
	}
}
