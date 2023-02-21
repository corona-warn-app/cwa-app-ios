//
// 🦠 Corona-Warn-App
//

import Foundation

#if !RELEASE

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
			var title = "App will shutdown after selecting a new date value in the date picker.\n\nCurrently the hibernation threshold compares against the set date: \(dateFormatter.string(from: store.hibernationComparisonDate))"
			
			return title
		case .reset:
			return "App will shutdown after reseting to today's date."
		}
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationComparingDate:
			return DMDatePickerCellViewModel(
				title: "Hibernation Comparison Date",
				accessibilityIdentifier: AccessibilityIdentifiers.DeveloperMenu.Hibernation.datePicker,
				datePickerMode: .date,
				date: store.hibernationComparisonDate
			)
		case .reset:
			return DMButtonCellViewModel(
				text: "Reset Comparison Date",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive)
			) { [weak self] in
				self?.store(hibernationComparisonDate: Date())
			}
		}
	}
	
	func store(hibernationComparisonDate: Date) {
		Log.debug("[Debug-Menu] Set hibernation comparison date to: \(dateFormatter.string(from: hibernationComparisonDate)).")
		store.hibernationComparisonDate = hibernationComparisonDate
		
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
	enum Sections: Int, CaseIterable {
		/// The date, that will be used to compare it against the hibernation start date (01.06.2023)
		case hibernationComparingDate
		/// Reset the stored fake date, the hibernation threshold compares to
		case reset
	}
}

#endif
