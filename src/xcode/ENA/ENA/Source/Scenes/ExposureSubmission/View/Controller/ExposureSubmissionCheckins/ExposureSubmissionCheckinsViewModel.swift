////
// 🦠 Corona-Warn-App
//

import Foundation

class ExposureSubmissionCheckinsViewModel {
	
	// MARK: - Init
	
	init(checkins: [Checkin]) {
		self.checkinCellModels = checkins
			.filter { $0.checkinCompleted } // Only shows completed check-ins
			.map { ExposureSubmissionCheckinCellModel(checkin: $0) }
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	enum Section: Int, CaseIterable {
		case description
		case checkins
	}
	
	let title = AppStrings.ExposureSubmissionCheckins.title
	let checkinCellModels: [ExposureSubmissionCheckinCellModel]
	
	var numberOfSections: Int {
		Section.allCases.count
	}
	
	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return 1
		case .checkins:
			return checkinCellModels.count
		case .none:
			fatalError("Invalid section")
		}
	}
	
	@objc
	func selectAll() {
		print("SELECT ALL!")
		
	}
	
	// MARK: - Private
	
	
}
