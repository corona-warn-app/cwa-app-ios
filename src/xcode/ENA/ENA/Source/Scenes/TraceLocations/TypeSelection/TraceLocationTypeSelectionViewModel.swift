//
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceLocationTypeSelectionViewModel {

	// MARK: - Init

	init(
		_ allValues: [TraceLocationSection: [TraceLocationType]],
		onTraceLocationTypeSelection: @escaping (TraceLocationType) -> Void
	) {
		self.allValues = allValues
		self.onTraceLocationTypeSelection = onTraceLocationTypeSelection
	}

	// MARK: - Internal

	enum TraceLocationSection: Int, CaseIterable {
		case location
		case event

		var title: String {
			switch self {
			case .location:
				return AppStrings.TraceLocations.permanent.name
			case .event:
				return AppStrings.TraceLocations.temporary.name
			}
		}
	}

	var numberOfSections: Int {
		allValues.keys.count
	}

	func numberOfRows(in section: Int) -> Int {
		guard let traceLocationSection = TraceLocationSection(rawValue: section),
			  let traceLocations = allValues[traceLocationSection] else {
			return 0
		}
		return traceLocations.count
	}

	func sectionTitle(for index: Int) -> String {
		TraceLocationSection.allCases[index].title
	}

	func cellViewModel(at indexPath: IndexPath) -> TraceLocationType {
		guard let traceLocationSection = TraceLocationSection(rawValue: indexPath.section),
			  let traceLocationType = allValues[traceLocationSection]?[indexPath.row] else {
			Log.debug("missing TraceLocationType")
			return .locationTypeUnspecified
		}
		return traceLocationType
	}

	func selectTraceLocationType(at indexPath: IndexPath) {
		guard let traceLocationSection = TraceLocationSection(rawValue: indexPath.section),
			  let traceLocationType = allValues[traceLocationSection]?[indexPath.row] else {
			Log.debug("Failed to select a TraceLocationType")
			return
		}
		onTraceLocationTypeSelection(traceLocationType)
	}

	// MARK: - Private

	private let onTraceLocationTypeSelection: (TraceLocationType) -> Void
	private let allValues: [TraceLocationSection: [TraceLocationType]]

}
