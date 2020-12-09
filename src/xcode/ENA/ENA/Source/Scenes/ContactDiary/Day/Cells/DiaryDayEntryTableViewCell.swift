////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(entry: DiaryEntry) {
		switch entry {
		case .contactPerson(let contactPerson):
			checkboxImageView.image = contactPerson.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
			label.text = contactPerson.name
		case .location(let location):
			checkboxImageView.image = location.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
			label.text = location.name
		}
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
	@IBOutlet private weak var checkboxImageView: UIImageView!

}
