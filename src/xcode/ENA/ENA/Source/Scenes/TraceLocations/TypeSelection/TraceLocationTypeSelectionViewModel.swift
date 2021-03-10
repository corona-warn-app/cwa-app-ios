//
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceLocationTypeSelectionViewModel {

	// MARK: - Init

	init(
		onTraceLocationTypeSelection: @escaping (TraceLocationType) -> Void
	) {
		self.onTraceLocationTypeSelection = onTraceLocationTypeSelection
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case location
		case traceLocation
	}

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .location:
			return 1
		case .traceLocation:
			return 1
		case .none:
			fatalError("Invalid section")
		}
	}

	func sectionTitle(for index: Int) -> String {
		switch Section.allCases[index] {
		case .location:
			return AppStrings.TraceLocations.TypeSelection.locationSectionTitle
		case .traceLocation:
			return AppStrings.TraceLocations.TypeSelection.eventSectionTitle
		}
	}

	func title(at indexPath: IndexPath) -> String {
		switch Section(rawValue: indexPath.section) {
		case .location:
			return AppStrings.TraceLocations.TypeSelection.otherLocationTitle
		case .traceLocation:
			return AppStrings.TraceLocations.TypeSelection.otherEventTitle
		case .none:
			fatalError("Invalid section")
		}
	}

	func description(at indexPath: IndexPath) -> String? {
		switch Section(rawValue: indexPath.section) {
		case .location:
			return nil
		case .traceLocation:
			return nil
		case .none:
			fatalError("Invalid section")
		}
	}

	func selectTraceLocationType(at indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section) {
		case .location:
			onTraceLocationTypeSelection(locationTypes[indexPath.row])
		case .traceLocation:
			onTraceLocationTypeSelection(traceLocationTypes[indexPath.row])
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let onTraceLocationTypeSelection: (TraceLocationType) -> Void

	private let locationTypes: [TraceLocationType] = [.type1]
	private let traceLocationTypes: [TraceLocationType] = [.type2]

}
