//
// 🦠 Corona-Warn-App
//

import Foundation

#if !RELEASE

class DMHibernationOptionsViewModel {
	
	// MARK: - Init
	
	init(store: Store) {
		self.store = store
		self.customHibernationStartDateSelected = CWAHibernationProvider.shared.hibernationStartDateForBuild
	}
	
	// MARK: - Internal
	
	var customHibernationStartDateSelected: Date
	
	var numberOfSections: Int { Sections.allCases.count }
	
	func numberOfRows(in section: Int) -> Int { 1 }
	
	func titleForFooter(in section: Int) -> String? {
		guard let section = Sections(rawValue: section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationStartDate:
			if let customHibernationStartDate = store.hibernationStartDate {
				return "App will shutdown after selecting a new date.\nCurrently the (custom) hibernation starts on: \(dateFormatter.string(from: customHibernationStartDate))"
			} else {
				return "App will shutdown after selecting a new date.\nCurrently the  (default) hibernation starts on: \(dateFormatter.string(from: CWAHibernationProvider.shared.hibernationStartDateForBuild))"
			}
		case .storeButton:
			return nil
		case .reset:
			return "App will shutdown after reset."
		}
	}
	
	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableView section")
		}
		
		switch section {
		case .hibernationStartDate:
			return DMDatePickerCellViewModel(
				title: "Hibernation Comparison Date",
				accessibilityIdentifier: AccessibilityIdentifiers.DeveloperMenu.Hibernation.datePicker,
				datePickerMode: .dateAndTime,
				date: CWAHibernationProvider.shared.hibernationStartDateForBuild
			)
		case .storeButton:
			return DMButtonCellViewModel(
				text: "Save Custom Start Date",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary)
			) { [weak self] in
				guard let self = self else { return }
				self.store(hibernationStartDate: self.customHibernationStartDateSelected)
			}
		case .reset:
			return DMButtonCellViewModel(
				text: "Reset",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive)
			) { [weak self] in
				self?.store(hibernationStartDate: CWAHibernationProvider.shared.hibernationStartDateDefault)
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
		Log.debug("[Debug-Menu] Set hibernation start date to: \(dateFormatter.string(from: hibernationStartDate)).")
		store.hibernationStartDate = hibernationStartDate
		Log.debug("[Debug-Menu] Set hibernation start saved.")
		
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
