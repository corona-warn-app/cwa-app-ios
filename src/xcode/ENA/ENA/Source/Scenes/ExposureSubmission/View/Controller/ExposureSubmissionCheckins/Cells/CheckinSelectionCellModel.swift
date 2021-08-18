////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinSelectionCellModel: TraceLocationCheckinSelectionCellModel {
	
	// MARK: - Init
	
	init(checkin: Checkin) {
		self.checkin = checkin
	}

	// MARK: - Internal
	
	let checkin: Checkin
	
	var description: String {
		checkin.traceLocationDescription
	}

	var address: String {
		checkin.traceLocationAddress
	}
		
	var dateInterval: String? {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short

		return dateFormatter.string(from: checkin.checkinStartDate, to: checkin.checkinEndDate)
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
