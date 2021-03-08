//
// 🦠 Corona-Warn-App
//

import Foundation

struct EventTypeSelectionViewModel {

	// MARK: - Init

	init(
		onEventTypeSelection: @escaping (EventType) -> Void
	) {
		self.onEventTypeSelection = onEventTypeSelection
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case location
		case event
	}

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .location:
			return 1
		case .event:
			return 1
		case .none:
			fatalError("Invalid section")
		}
	}

	func sectionTitle(for index: Int) -> String {
		switch Section.allCases[index] {
		case .location:
			return AppStrings.EventPlanning.TypeSelection.locationSectionTitle
		case .event:
			return AppStrings.EventPlanning.TypeSelection.eventSectionTitle
		}
	}

	func title(at indexPath: IndexPath) -> String {
		switch Section(rawValue: indexPath.section) {
		case .location:
			return AppStrings.EventPlanning.TypeSelection.otherLocationTitle
		case .event:
			return AppStrings.EventPlanning.TypeSelection.otherEventTitle
		case .none:
			fatalError("Invalid section")
		}
	}

	func description(at indexPath: IndexPath) -> String? {
		switch Section(rawValue: indexPath.section) {
		case .location:
			return nil
		case .event:
			return nil
		case .none:
			fatalError("Invalid section")
		}
	}

	func selectEventType(at indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section) {
		case .location:
			onEventTypeSelection(locationTypes[indexPath.row])
		case .event:
			onEventTypeSelection(eventTypes[indexPath.row])
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let onEventTypeSelection: (EventType) -> Void

	private let locationTypes: [EventType] = [.otherLocation]
	private let eventTypes: [EventType] = [.otherEvent]

}
