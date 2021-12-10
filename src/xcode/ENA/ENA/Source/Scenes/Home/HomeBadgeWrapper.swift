//
// 🦠 Corona-Warn-App
//

import Foundation

final class HomeBadgeWrapper {

	// MARK: - Init

	init(
		_ values: [Badges: Int?]
	) {
		badgesCount = values
	}

	convenience init() {
		self.init([:])
	}

	// MARK: - Internal

	enum Badges: Int, CaseIterable, Hashable {
		case unseenTests = 0
		case riskStateIncreased
	}

	var updateView: ((String?) -> Void)?

	func update(_ badgeCount: Badges, value: Int?) {
		badgesCount[badgeCount] = value
		updateView?(badgeValueString)
	}

	func reset(_ badgeCount: Badges) {
		update(badgeCount, value: nil)
	}

	func resetAll() {
		badgesCount = [:]
		updateView?(badgeValueString)
	}

	// MARK: - Private

	private var badgesCount: [Badges: Int?] = [:]

	private var badgeValueString: String? {
		let value = badgesCount.values.compactMap { $0 }.reduce(0, +)
		return value == 0 ? nil : String(value)
	}

}
