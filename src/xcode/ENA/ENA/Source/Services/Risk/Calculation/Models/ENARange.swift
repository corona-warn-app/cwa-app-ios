//
// 🦠 Corona-Warn-App
//

import Foundation

struct ENARange: Codable {

	// MARK: - Init

	init(from range: SAP_Internal_V2_Range) {
		self.min = range.min
		self.max = range.max
		self.minExclusive = range.minExclusive
		self.maxExclusive = range.maxExclusive
	}

	// MARK: - Internal

	func contains(_ value: Double) -> Bool {
		let minExclusive = self.minExclusive ?? false
		let maxExclusive = self.maxExclusive ?? false

		if minExclusive && value <= min { return false }
		if !minExclusive && value < min { return false }
		if maxExclusive && value >= max { return false }
		if !maxExclusive && value > max { return false }

		return true
	}

	func contains(_ value: Int) -> Bool {
		contains(Double(value))
	}

	func contains(_ value: UInt8) -> Bool {
		contains(Double(value))
	}

	// MARK: - Private

	private let min: Double
	private let max: Double

	private let minExclusive: Bool?
	private let maxExclusive: Bool?

}
