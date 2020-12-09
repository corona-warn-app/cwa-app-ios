////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayAddTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(entryType: DiaryEntryType) {
		switch entryType {
		case .contactPerson:
			label.text = AppStrings.ContactDiary.Day.addContactPerson
		case .location:
			label.text = AppStrings.ContactDiary.Day.addLocation
		}
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
    
}
