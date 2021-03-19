//
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceLocationTypeSelectionViewModel {

	// MARK: - Init

	init(
		_ allValues: [TraceLocationSection: [TraceLocationType]],
//		preselected: TraceLocationType?,
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

	func title(at indexPath: IndexPath) -> String {
		guard let traceLocationSection = TraceLocationSection(rawValue: indexPath.section),
			  let traceLocationType = allValues[traceLocationSection]?[indexPath.row] else {
			Log.debug("unknown section")
			return ""
		}
		return traceLocationType.title
	}

	func cellViewModel(at indexPath: IndexPath) -> TraceLocationType {
		guard let traceLocationSection = TraceLocationSection(rawValue: indexPath.section),
			  let traceLocationType = allValues[traceLocationSection]?[indexPath.row] else {
			fatalError("unknown tracelocationtype")
		}
		return traceLocationType
	}
	func description(at indexPath: IndexPath) -> String? {
		switch TraceLocationSection(rawValue: indexPath.section) {
		case .location:
			return nil
		case .event:
			return nil
		case .none:
			fatalError("Invalid section")
		}
	}

	
	func selectTraceLocationType(at indexPath: IndexPath) {
		/*
		switch TraceLocationSection(rawValue: indexPath.section) {
		case .location:
			onTraceLocationTypeSelection(locationTypes[indexPath.row])
		case .traceLocation:
			onTraceLocationTypeSelection(traceLocationTypes[indexPath.row])
		case .none:
			fatalError("Invalid section")
		}
*/
	}

	// MARK: - Private

	private let onTraceLocationTypeSelection: (TraceLocationType) -> Void

//	private let locationTypes: [TraceLocationType] = [. ]
//	private let traceLocationTypes: [TraceLocationType] = [.locationTypePermanentOther]

	private let allValues: [TraceLocationSection: [TraceLocationType]]

}
