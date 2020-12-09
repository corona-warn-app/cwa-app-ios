////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(entry: DiaryEntry) {
		switch entry {
		case .contactPerson(let contactPerson):
			imageView.image = contactPerson.isSelected ? UIImage(named: "Icons_Diary_ContactPerson") : 
			label.text = contactPerson.name
		case .location(let location):
			imageView.image = UIImage(named: "Icons_Diary_Location")
			label.text = location.name
		}
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
	@IBOutlet private weak var imageView: UIImageView!

}
