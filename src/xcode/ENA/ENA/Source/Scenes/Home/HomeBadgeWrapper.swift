//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HomeBadgeWrapper {

	// MARK: - Init

	init(
		_ store: HomeBadgeStoring,
		badgesCount: [BadgeType: Int?] = [:]
	) {
		self.store = store
		self.badgesCount = badgesCount
		
		// we only load data if not injected
		guard badgesCount.isEmpty else {
			self.badgesCount = badgesCount
			return
		}
		load()
	}

	// MARK: - Internal

	enum BadgeType: Int, CaseIterable, Codable {
		case unseenTests = 0
		case riskStateChanged
	}

	@OpenCombine.Published private(set) var stringValue: String?

	func increase(_ badgeType: BadgeType, by value: Int) {
		let oldValue = badgesCount[badgeType] ?? 0
		badgesCount[badgeType] = (oldValue ?? 0) + value
		saveAndUpdate()
	}

	func update(_ badgeType: BadgeType, value: Int?) {
		badgesCount[badgeType] = value
		saveAndUpdate()
	}

	func reset(_ badgeType: BadgeType) {
		update(badgeType, value: nil)
	}

	func resetAll() {
		badgesCount = [:]
		saveAndUpdate()
	}

	// MARK: - Private

	private let store: HomeBadgeStoring

	private var badgesCount: [BadgeType: Int?] = [:]

	private func saveAndUpdate() {
		// serialize change to store and update string value for UI
		save()
		stringValue = processedBadgeCountString
	}

	private var processedBadgeCountString: String? {
		let value = badgesCount.values.compactMap { $0 }.reduce(0, +)
		return value == 0 ? nil : String(value)
	}

	private func save() {
		store.badgesData = badgesCount
	}

	private func load() {
		badgesCount = store.badgesData
		stringValue = processedBadgeCountString
	}
}
