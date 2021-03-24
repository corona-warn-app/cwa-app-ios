//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIColor
import OpenCombine

class TraceLocationConfigurationViewModel {

	enum Mode {
		case new(TraceLocationType)
		case duplicate(TraceLocation)
	}

	// MARK: - Init

	init(
		mode: Mode
	) {
		self.mode = mode

		switch mode {
		case .new(let type):
			traceLocationType = type
		case .duplicate(let traceLocation):
			traceLocationType = traceLocation.type
			description = traceLocation.description
			address = traceLocation.address
			startDate = traceLocation.startDate
			endDate = traceLocation.endDate
			defaultCheckInLengthInMinutes = traceLocation.defaultCheckInLengthInMinutes
		}
	}

	// MARK: - Internal

	@OpenCombine.Published var startDatePickerIsHidden: Bool = true
	@OpenCombine.Published var endDatePickerIsHidden: Bool = true
	@OpenCombine.Published var temporaryDefaultLengthPickerIsHidden: Bool = true
	@OpenCombine.Published var permanentDefaultLengthPickerIsHidden: Bool = true

	@OpenCombine.Published var description: String! = ""
	@OpenCombine.Published var address: String! = ""
	@OpenCombine.Published var startDate: Date?
	@OpenCombine.Published var endDate: Date?

	var traceLocationTypeTitle: String {
		traceLocationType.title
	}

	var temporarySettingsContainerIsHidden: Bool {
		traceLocationType.type != .temporary
	}

	var permanentSettingsContainerIsHidden: Bool {
		traceLocationType.type != .permanent
	}

	func startDateHeaderTapped() {
		startDatePickerIsHidden.toggle()

		if !startDatePickerIsHidden {
			endDatePickerIsHidden = true
		}
	}

	func endDateHeaderTapped() {
		endDatePickerIsHidden.toggle()

		if !endDatePickerIsHidden {
			startDatePickerIsHidden = true
		}
	}

	func temporaryDefaultLengthHeaderTapped() {
		temporaryDefaultLengthPickerIsHidden.toggle()
	}

	func permanentDefaultLengthHeaderTapped() {
		permanentDefaultLengthPickerIsHidden.toggle()
	}

	func save(completion: @escaping (Bool) -> Void) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			completion(true)
		}
	}

	// MARK: - Private

	private let mode: Mode

	private let traceLocationType: TraceLocationType
	private var defaultCheckInLengthInMinutes: Int?

}
