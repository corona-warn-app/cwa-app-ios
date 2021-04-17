////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionCheckinCellModel {
	
	// MARK: - Init
	
	init(checkin: Checkin) {
		self.checkin = checkin
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	let checkin: Checkin
	
	var description: String {
		checkin.traceLocationDescription
	}

	var address: String {
		checkin.traceLocationAddress
	}
		
	var dateInterval: String {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short

		return dateFormatter.string(from: checkin.checkinStartDate, to: checkin.checkinEndDate)
	}
	
	var selected: Bool = false {
		didSet {
			checkmarkImage = selected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
		}
	}
	
	@OpenCombine.Published var checkmarkImage = UIImage(named: "Diary_Checkmark_Unselected")
	
	// MARK: - Private

}
