////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol EventCellModel {

	var isInactiveIconHiddenPublisher: OpenCombine.Published<Bool>.Publisher { get }
	var isActiveContainerViewHiddenPublisher: OpenCombine.Published<Bool>.Publisher { get }
	var durationPublisher: OpenCombine.Published<String?>.Publisher { get }

	var isActiveIconHidden: Bool { get }
	var isDurationStackViewHidden: Bool { get }

	var date: String { get }

	var title: String { get }
	var address: String { get }
	var time: String { get }

	var buttonTitle: String { get }

}

class TraceLocationCellModel: EventCellModel {

	// MARK: - Init

	init(traceLocation: TraceLocation) {
		self.traceLocation = traceLocation
	}

	// MARK: - Internal

	var isInactiveIconHiddenPublisher: OpenCombine.Published<Bool>.Publisher { $isInactiveIconHidden }
	var isActiveContainerViewHiddenPublisher: OpenCombine.Published<Bool>.Publisher { $isActiveContainerViewHidden }
	var durationPublisher: OpenCombine.Published<String?>.Publisher { $duration }

	var isActiveIconHidden: Bool = false
	var isDurationStackViewHidden: Bool = true

	var date: String {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		return dateFormatter.string(from: traceLocation.startDate, to: traceLocation.endDate)
	}

	var title: String {
		traceLocation.description
	}

	var address: String {
		traceLocation.address
	}

	var time: String {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .none
		dateFormatter.timeStyle = .short

		return dateFormatter.string(from: traceLocation.startDate, to: traceLocation.endDate)
	}

	var buttonTitle: String = AppStrings.TraceLocations.Overview.selfCheckinButtonTitle

	// MARK: - Private

	private let traceLocation: TraceLocation

	@OpenCombine.Published private var isInactiveIconHidden: Bool = true
	@OpenCombine.Published private var isActiveContainerViewHidden: Bool = true
	@OpenCombine.Published private var duration: String?
    
}

private extension TraceLocation {

	var isActive: Bool {
		Date() < endDate
	}

}
