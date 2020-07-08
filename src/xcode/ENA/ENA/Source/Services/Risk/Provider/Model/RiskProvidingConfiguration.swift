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

/// Either a concrete date or now
enum NextExposureDetection: Equatable {
	case date(Date)
	case now

	static func == (lhs: NextExposureDetection, rhs: NextExposureDetection) -> Bool {
		switch (lhs, rhs) {
		case (.now, .now):
			return true
		case let (.date(a), .date(b)):
			// return true if dates are less than 30 seconds apart
			return abs(a.timeIntervalSince(b)) < 30.0
		default:
			return false
		}
	}
}

extension RiskProvidingConfiguration {
	func exposureDetectionValidUntil(lastExposureDetectionDate: Date?) -> Date {
		Calendar.current.date(
			byAdding: exposureDetectionValidityDuration,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
			) ?? .distantPast
	}

	func nextExposureDetectionDate(lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> NextExposureDetection {
		let potentialDate = Calendar.current.date(
			byAdding: exposureDetectionInterval,
			to: lastExposureDetectionDate ?? .distantPast,
			wrappingComponents: false
			) ?? .distantPast
		return potentialDate > currentDate ? .date(potentialDate) : .now
	}

	func exposureDetectionIsValid(lastExposureDetectionDate: Date = .distantPast, currentDate: Date = Date()) -> Bool {
		// It is not valid to have a future exposure detection date
		guard lastExposureDetectionDate <= currentDate else { return false }

		return currentDate < exposureDetectionValidUntil(lastExposureDetectionDate: lastExposureDetectionDate)
	}

	/// Checks, whether a new exposureDetection may be triggered
	///
	/// - Parameters:
	///     - activeTracingHours: The amount of hours where the contact tracing protocol has been active within the relevant timeframe.
	///     - lastExposureDetectionDate: The timestamp when the last exposureDetection completed successfully.
	///     - currentDate: Current timestamp.
	func shouldPerformExposureDetection(activeTracingHours: Int, lastExposureDetectionDate: Date?, currentDate: Date = Date()) -> Bool {
		// Don't allow exposure detection within the first frame of exposureDetectionInterval
		guard activeTracingHours >= TracingStatusHistory.minimumActiveHours else {
			return false
		}

		if let lastExposureDetectionDate = lastExposureDetectionDate, lastExposureDetectionDate > currentDate {
			// It is not valid to have a future exposure detection date.
			return true
		}
		let next = nextExposureDetectionDate(lastExposureDetectionDate: lastExposureDetectionDate, currentDate: currentDate)

		switch next {
		case .now:
			return true
		case .date(let date):
			return date <= currentDate
		}
	}

	/// Checks, whether a new exposureDetection may be triggered manually by the user.
	///
	/// - Parameters:
	///     - activeTracingHours: The amount of hours where the contact tracing protocol has been active within the relevant timeframe.
	///     - lastExposureDetectionDate: The timestamp when the last exposureDetection completed successfully.
	func manualExposureDetectionState(activeTracingHours: Int, lastExposureDetectionDate detectionDate: Date?) -> ManualExposureDetectionState? {
		guard detectionMode != .automatic else {
			return nil
		}
		return shouldPerformExposureDetection(activeTracingHours: activeTracingHours, lastExposureDetectionDate: detectionDate) ? .possible : .waiting
	}
}
