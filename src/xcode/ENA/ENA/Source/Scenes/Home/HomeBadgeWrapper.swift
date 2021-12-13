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
		
		load()
	}

	// MARK: - Internal

	enum BadgeType: Int, CaseIterable, Codable {
		case unseenTests = 0
		case riskStateIncreased
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
		stringValue = processBadgeCountString
	}

	private var processBadgeCountString: String? {
		let value = badgesCount.values.compactMap { $0 }.reduce(0, +)
		return value == 0 ? nil : String(value)
	}

	private func save() {
		let encoder = JSONEncoder()
		do {
			store.badgesData = try encoder.encode(badgesCount)
		} catch {
			Log.error("Failed to serialize HomeBadgeWrapper data")
		}
	}

	private func load() {
		let decoder = JSONDecoder()
		do {
			badgesCount = try decoder.decode([BadgeType: Int?].self, from: store.badgesData)
			stringValue = processBadgeCountString
		} catch {
			Log.error("Failed to deserialize HomeBadgeWrapper data")
		}
	}
}
