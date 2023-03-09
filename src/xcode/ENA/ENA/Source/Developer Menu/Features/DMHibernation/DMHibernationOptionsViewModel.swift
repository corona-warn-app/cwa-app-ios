//
// 🦠 Corona-Warn-App
//

import Foundation

#if !RELEASE

class DMHibernationOptionsViewModel {
	
	// MARK: - Init
	
	init(store: Store) {
		self.store = store
		self.hibernationComparisonDateSelected = store.hibernationStartDate
	}
	
	// MARK: - Internal
	
	var hibernationComparisonDateSelected: Date
	
	var numberOfSections: Int { Sections.allCases.count }
	
	func numberOfRows(in section: Int) -> Int { 1 }
	
	func titleForFooter(in section: Int) -> String? {
		guard let section = Sections(rawValue: section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationStartDate:
			return "App will shutdown after selecting a new date value in the date picker.\n\nCurrently the hibernation threshold compares against the set date: \(dateFormatter.string(from: store.hibernationStartDate))"
		case .storeButton:
			return nil
		case .reset:
			return "App will shutdown after reseting to today's date."
		}
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationStartDate:
			return DMDatePickerCellViewModel(
				title: "Hibernation Start Date",
				accessibilityIdentifier: AccessibilityIdentifiers.DeveloperMenu.Hibernation.datePicker,
				datePickerMode: .dateAndTime,
				date: store.hibernationStartDate
			)
		case .storeButton:
			return DMButtonCellViewModel(
				text: "Save Comparison Date",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary)
			) { [weak self] in
				guard let self = self else { return }
				self.store(hibernationStartDate: self.hibernationComparisonDateSelected)
			}
		case .reset:
			return DMButtonCellViewModel(
				text: "Reset Comparison Date",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive)
			) { [weak self] in
				self?.store(hibernationStartDate: Date())
			}
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm"
		return dateFormatter
	}()

	private func store(hibernationStartDate: Date) {
		Log.debug("[Debug-Menu] Set hibernation comparison date to: \(dateFormatter.string(from: hibernationStartDate)).")
		store.hibernationStartDate = hibernationStartDate
		Log.debug("did save ")
		
		exitApp()
	}
	
	private func exitApp() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			exit(0)
		}
	}
}

extension DMHibernationOptionsViewModel {
	enum Sections: Int, CaseIterable {
		/// The date, that will be used to compare it against the hibernation start date.
		case hibernationStartDate
		/// Store the set hibernation comparison date
		case storeButton
		/// Reset the stored fake date, the hibernation threshold compares to.
		case reset
	}
}

#endif
