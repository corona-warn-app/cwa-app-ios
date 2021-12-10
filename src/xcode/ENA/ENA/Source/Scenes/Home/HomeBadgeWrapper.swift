//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class HomeBadgeWrapper {

	// MARK: - Init

	init() {
		self.badgesCount = [:]
	}

	init(
		values: [BadgeTyoe: Int?] = [:],
		updateView: @escaping (String?) -> Void
	) {
		self.badgesCount = values
	}

	// MARK: - Internal

	enum BadgeTyoe: Int, CaseIterable {
		case unseenTests = 0
		case riskStateIncreased
	}

	@OpenCombine.Published private(set) var stringValue: String?

	func increase(_ badgeType: BadgeTyoe, by value: Int) {
		let oldValue = badgesCount[badgeType] ?? 0
		badgesCount[badgeType] = (oldValue ?? 0) + value
	}

	func update(_ badgeType: BadgeTyoe, value: Int?) {
		badgesCount[badgeType] = value
		stringValue = processBadgeCountString
	}

	func reset(_ badgeType: BadgeTyoe) {
		update(badgeType, value: nil)
	}

	func resetAll() {
		badgesCount = [:]
		stringValue = processBadgeCountString
	}

	// MARK: - Private

	private var badgesCount: [BadgeTyoe: Int?] = [:]

	private var processBadgeCountString: String? {
		let value = badgesCount.values.compactMap { $0 }.reduce(0, +)
		return value == 0 ? nil : String(value)
	}

}
