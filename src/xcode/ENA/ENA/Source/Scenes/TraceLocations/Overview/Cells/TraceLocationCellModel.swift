////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationCellModel: EventCellModel {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		eventProvider: EventProviding,
		onUpdate: @escaping () -> Void
	) {
		self.traceLocation = traceLocation
		self.onUpdate = onUpdate

		// Set initial value so onUpdate isn't triggered on initial publisher call
		isButtonHiddenPublisher.value = eventProvider.checkinsPublisher.value.contains { $0.traceLocationId == traceLocation.id && !$0.checkinCompleted }

		eventProvider.checkinsPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] checkins in
				let isButtonHiddenPublisher = checkins.contains { $0.traceLocationId == traceLocation.id && !$0.checkinCompleted }

				if self?.isButtonHiddenPublisher.value != isButtonHiddenPublisher {
					self?.isButtonHiddenPublisher.value = isButtonHiddenPublisher
					onUpdate()
				}
			}
			.store(in: &subscriptions)

		timePublisher.value = timeString
	}

	// MARK: - Internal

	var isInactiveIconHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var isActiveContainerViewHiddenPublisher = CurrentValueSubject<Bool, Never>(false)
	var isButtonHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var durationPublisher = CurrentValueSubject<String?, Never>(nil)
	var timePublisher = CurrentValueSubject<String?, Never>(nil)

	var isActiveIconHidden: Bool = false
	var isDurationStackViewHidden: Bool = true

	var date: String? {
		guard let startDate = traceLocation.startDate, let endDate = traceLocation.endDate else {
			return nil
		}

		if !Calendar.current.isDate(startDate, inSameDayAs: endDate) {
			// Multi-day events show the full dates in the time label
			return nil
		}

		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		return dateFormatter.string(from: startDate, to: endDate)
	}

	var title: String {
		traceLocation.description
	}

	var address: String {
		traceLocation.address
	}

	var buttonTitle: String = AppStrings.TraceLocations.Overview.selfCheckinButtonTitle

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let onUpdate: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	private var timeString: String? {
		if let startDate = traceLocation.startDate, let endDate = traceLocation.endDate {
			let endsOnSameDay = Calendar.current.isDate(startDate, inSameDayAs: endDate)

			let dateFormatter = DateIntervalFormatter()
			dateFormatter.dateStyle = endsOnSameDay ? .none : .short
			dateFormatter.timeStyle = .short

			return dateFormatter.string(from: startDate, to: endDate)
		} else {
			return nil
		}
	}
    
}
