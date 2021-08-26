////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationSelectionCellModel: TraceLocationCheckinSelectionCellModel {
	
	// MARK: - Init
	
	init(traceLocation: TraceLocation) {
		self.traceLocation = traceLocation
	}

	// MARK: - Internal
	
	let traceLocation: TraceLocation
	
	var description: String {
		traceLocation.description
	}

	var address: String {
		traceLocation.address
	}
		
	var dateInterval: String? {
		guard let startDate = traceLocation.startDate, let endDate = traceLocation.endDate else {
			return nil
		}

		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short

		return dateFormatter.string(from: startDate, to: endDate)
	}
	
	var selected: Bool = false {
		didSet {
			cellIsSelected.value = selected
			checkmarkImage.value = selected ? UIImage(named: "Checkin_Checkmark_Selected") : UIImage(named: "Checkin_Checkmark_Unselected")
		}
	}

	private(set) var cellIsSelected = CurrentValueSubject<Bool, Never>(false)
	private(set) var checkmarkImage = CurrentValueSubject<UIImage?, Never>(UIImage(named: "Checkin_Checkmark_Unselected"))

}
