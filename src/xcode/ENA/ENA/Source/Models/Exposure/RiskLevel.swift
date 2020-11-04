import ExposureNotification
import Foundation

/// Exposure Risk level
///
/// - important: Due to exception case, `CaseIterable` `allCases` does not produce a correctly sorted collection!
enum RiskLevel: Int, CaseIterable, Equatable {
	/*
	Generally, the risk level hiearchy is as the raw values in the enum cases state. .low is lowest and .inactive highest.
	The risk calculation itself takes multiple parameters into account, for example how long tracing has been active for,
	and the date of the last exposure detection.

	There is one special situation where the hierarchy defined below is not followed. Assume:
	- Last exposure detection is more than 48 hours old -> .unknownOutdated applies
	- Summary & AppConfig resolve to .increased risk
	- Tracing has been active for more than 24 hours

	According to the hierarchy we should return .increased risk. In this case however .unknownOutdated should be returned!
	*/

	/// Low risk
	case low = 0
	/// Unknown risk  last calculation more than 24 hours old
	///
	/// Will be shown when the last calculation is more than 24 hours old - until the calculation is run again
	case unknownOutdated
	/// Unknown risk - no calculation has been performed yet or tracing has been active for less than 24h
	case unknownInitial
	/// Increased risk
	case increased
	/// No calculation possible - tracing is inactive
	///
	/// - important: Should always be displayed, even if a different risk level has been calculated. It overrides all other levels!
	case inactive
}

extension RiskLevel: Comparable {
	static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}
