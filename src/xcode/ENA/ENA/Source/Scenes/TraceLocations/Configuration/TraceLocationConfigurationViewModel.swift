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
	}

	// MARK: - Internal

	@OpenCombine.Published var isStartDatePickerHidden: Bool = true
	@OpenCombine.Published var isEndDatePickerHidden: Bool = true
	@OpenCombine.Published var isTemporaryDefaultLengthPickerHidden: Bool = true
	@OpenCombine.Published var isPermanentDefaultLengthPickerHidden: Bool = true

	func startDateHeaderTapped() {
		isStartDatePickerHidden.toggle()

		if !isStartDatePickerHidden {
			isEndDatePickerHidden = true
		}
	}

	func endDateHeaderTapped() {
		isEndDatePickerHidden.toggle()

		if !isEndDatePickerHidden {
			isStartDatePickerHidden = true
		}
	}

	func temporaryDefaultLengthHeaderTapped() {
		isTemporaryDefaultLengthPickerHidden.toggle()
	}

	func permanentDefaultLengthHeaderTapped() {
		isPermanentDefaultLengthPickerHidden.toggle()
	}

	func save(completion: @escaping (Bool) -> Void) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			completion(true)
		}
	}

	// MARK: - Private

	let mode: Mode

}
