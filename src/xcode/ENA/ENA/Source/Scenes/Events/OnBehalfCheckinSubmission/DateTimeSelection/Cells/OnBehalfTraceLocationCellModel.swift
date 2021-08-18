////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OnBehalfTraceLocationCellModel: EventCellModel {

	// MARK: - Init

	init(
		traceLocation: TraceLocation
	) {
		self.traceLocation = traceLocation

		timePublisher.value = timeString
		titleAccessibilityLabelPublisher.value = String(format: AppStrings.TraceLocations.Overview.itemPrefix, traceLocation.description)
	}

	// MARK: - Protocol EventCellModel

	var isInactiveIconHiddenPublisher = CurrentValueSubject<Bool, Never>(false)
	var isActiveContainerViewHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var isButtonHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var durationPublisher = CurrentValueSubject<String?, Never>(nil)
	var durationAccessibilityPublisher = CurrentValueSubject<String?, Never>(nil)
	var timePublisher = CurrentValueSubject<String?, Never>(nil)
	var timeAccessibilityPublisher = CurrentValueSubject<String?, Never>(nil)
	var titleAccessibilityLabelPublisher = CurrentValueSubject<String?, Never>(nil)

	var isActiveIconHidden: Bool = true
	var isDurationStackViewHidden: Bool = true

	var title: String {
		traceLocation.description
	}

	var address: String {
		traceLocation.address
	}

	var buttonTitle: String = ""

	// MARK: - Private

	private let traceLocation: TraceLocation

	private var timeString: String? {
		if let startDate = traceLocation.startDate, let endDate = traceLocation.endDate {
			let dateFormatter = DateIntervalFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short

			return dateFormatter.string(from: startDate, to: endDate)
		} else {
			return nil
		}
	}
    
}
