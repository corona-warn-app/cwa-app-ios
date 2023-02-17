//
// 🦠 Corona-Warn-App
//

import Foundation

class DMHibernationOptionsViewModel {
	
	// MARK: - Init
	
	init(store: Store) {
		self.store = store
	}
	
	// MARK: - Internal
	
	var numberOfSections: Int { Sections.allCases.count }
	
	func numberOfRows(in section: Int) -> Int { 1 }
	
	func titleForFooter(in section: Int) -> String {
		guard let section = Sections(rawValue: section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationComparingDate:
			var title = "App will be shutdown after set a new date value in the date picker.\n\nCurrently the hibernation threshold compares against the set date \(dateFormatter.string(from: store.hibernationComparingDate))"
			
			return title
		case .reset:
			return "App will be shutdown after reset to today date."
		}
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationComparingDate:
			return DMDatePickerCellViewModel(
				title: "Hibernation Comparing Date",
				accessibilityIdentifier: AccessibilityIdentifiers.DeveloperMenu.Hibernation.datePicker,
				datePickerMode: .date,
				date: store.hibernationComparingDate
			)
		case .reset:
			return DMButtonCellViewModel(
				text: "Reset Comparing Date",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive)) {
					self.store(hibernationComparingDate: Date())
				}
		}
	}
	
	func store(hibernationComparingDate: Date) {
		Log.debug("[Debug-Menu] Set hibernation comparing date to \(dateFormatter.string(from: hibernationComparingDate)).")
		store.hibernationComparingDate = hibernationComparingDate
		
		exitApp()
	}
	
	// MARK: - Private
	
	private let store: Store
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}()
	
	private func exitApp() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			exit(0)
		}
	}
}

extension DMHibernationOptionsViewModel {
	enum Sections :Int, CaseIterable {
		/// The date, that will be used to compare it against the hibernation start date (01.06.2023)
		case hibernationComparingDate
		/// Reset the stored fake date, the hibernation threshold compares to
		case reset
	}
}
