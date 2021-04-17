////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

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
	@OpenCombine.Published var continueEnabled: Bool = false
	
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
		checkinCellModels.forEach { $0.selected = true }
		checkContinuePossible()
	}
	
	func toogleSelection(at index: Int) {
		checkinCellModels[index].selected.toggle()
		checkContinuePossible()
	}
	
	// MARK: - Private
	
	func checkContinuePossible() {
		continueEnabled = checkinCellModels.contains(where: { $0.selected == true } )
	}
	
	
}
