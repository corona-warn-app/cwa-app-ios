//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

enum SymptomsOnset: Equatable, Codable {

	case noInformation
	case nonSymptomatic
	case symptomaticWithUnknownOnset
	case lastSevenDays
	case oneToTwoWeeksAgo
	case moreThanTwoWeeksAgo
	case daysSinceOnset(Int)

	// MARK: - Protocol Codable

	enum Key: CodingKey {
		case rawValue
		case associatedValue
	}

	enum CodingError: Error {
		case unknownValue
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Key.self)
		let rawValue = try container.decode(Int.self, forKey: .rawValue)
		switch rawValue {
		case 0:
			self = .noInformation
		case 1:
			self = .nonSymptomatic
		case 2:
			self = .symptomaticWithUnknownOnset
		case 3:
			self = .lastSevenDays
		case 4:
			self = .oneToTwoWeeksAgo
		case 5:
			self = .moreThanTwoWeeksAgo
		case 6:
			let daysSinceOnset = try container.decode(Int.self, forKey: .associatedValue)
			self = .daysSinceOnset(daysSinceOnset)
		default:
			throw CodingError.unknownValue
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Key.self)
		switch self {
		case .noInformation:
			try container.encode(0, forKey: .rawValue)
		case .nonSymptomatic:
			try container.encode(1, forKey: .rawValue)
		case .symptomaticWithUnknownOnset:
			try container.encode(2, forKey: .rawValue)
		case .lastSevenDays:
			try container.encode(3, forKey: .rawValue)
		case .oneToTwoWeeksAgo:
			try container.encode(4, forKey: .rawValue)
		case .moreThanTwoWeeksAgo:
			try container.encode(5, forKey: .rawValue)
		case .daysSinceOnset(let daysSinceOnset):
			try container.encode(6, forKey: .rawValue)
			try container.encode(daysSinceOnset, forKey: .associatedValue)
		}
	}

	// MARK: - Internal

	/// Transmission risk level by days since the exposure.
	/// These factors are applied to each `ENTemporaryExposureKey`'s `transmissionRiskLevel`
	///
	/// Index 0 of the array represents the day of the exposure
	/// Index 1 the next day, and so on.
	/// These factors are supplied by RKI
	///
	/// - see also: [Risk Score Calculation Docs](https://github.com/corona-warn-app/cwa-documentation/blob/master/solution_architecture.md#risk-score-calculation)
	var transmissionRiskVector: [Int32] {
		switch self {
		case .noInformation:
			return [5, 6, 7, 7, 7, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1]
		case .nonSymptomatic:
			return [4, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		case .symptomaticWithUnknownOnset:
			return [5, 6, 8, 8, 8, 7, 5, 3, 2, 1, 1, 1, 1, 1, 1]
		case .lastSevenDays:
			return [4, 5, 6, 7, 7, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1]
		case .oneToTwoWeeksAgo:
			return [1, 1, 1, 1, 2, 3, 4, 5, 6, 6, 7, 7, 6, 6, 4]
		case .moreThanTwoWeeksAgo:
			return [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5]
		case .daysSinceOnset(let daysSinceOnset):
			return SymptomsOnset.daysSinceOnsetRiskVectors[min(daysSinceOnset, 21)]
		}
	}

	/// Days since onset of symptoms according to https://github.com/corona-warn-app/cwa-app-tech-spec/blob/56521167b688f418127adde09a18a48f262af382/docs/spec/days-since-onset-of-symptoms.md
	var daysSinceOnsetOfSymptomsVector: [Int32] {
		switch self {
		case .noInformation:
			return Array(3986...4000).reversed()
		case .nonSymptomatic:
			return Array(2986...3000).reversed()
		case .symptomaticWithUnknownOnset:
			return Array(1986...2000).reversed()
		case .lastSevenDays:
			return Array(687...701).reversed()
		case .oneToTwoWeeksAgo:
			return Array(694...708).reversed()
		case .moreThanTwoWeeksAgo:
			return Array(701...715).reversed()
		case .daysSinceOnset(let daysSinceOnset):
			return Array(-14...0).reversed().map { Int32($0 + min(daysSinceOnset, 21)) }
		}
	}

	// MARK: - Private

	private static let daysSinceOnsetRiskVectors: [[Int32]] = [
		[8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1],
		[6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1],
		[5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1],
		[3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1],
		[2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1],
		[2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1],
		[1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1],
		[1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1],
		[1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2],
		[1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4],
		[1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6],
		[1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7],
		[1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8],
		[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	]

}
