////
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationCellModel {

	// MARK: - Init

	init(traceLocation: TraceLocation) {
		self.traceLocation = traceLocation

		configure(for: traceLocation)
	}

	// MARK: - Internal

	enum GradientCardMode {
		case duration
		case qrIcon
		case hidden
	}

	var title: String = ""
	var address: String = ""
	var time: String = ""
	var date: String = ""
	var buttonTitle: String = ""

	// MARK: - Private

	private let traceLocation: TraceLocation

	private func configure(for traceLocation: TraceLocation) {
		title = traceLocation.description
		address = traceLocation.address
		time = time(for: traceLocation)
		date = date(for: traceLocation)
		buttonTitle = AppStrings.TraceLocations.Overview.selfCheckinButtonTitle
	}

	private func time(for traceLocation: TraceLocation) -> String {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .none
		dateFormatter.timeStyle = .short

		return dateFormatter.string(from: traceLocation.startDate, to: traceLocation.endDate)
	}

	private func date(for traceLocation: TraceLocation) -> String {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		return dateFormatter.string(from: traceLocation.startDate, to: traceLocation.endDate)
	}
    
}
