////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryEditEntriesTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(entry: DiaryEntry) {
		switch entry {
		case .contactPerson(let contactPerson):
			label.text = contactPerson.name
		case .location(let location):
			label.text = location.name
		}
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!

}
