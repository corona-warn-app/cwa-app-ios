////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryEditEntriesCellModel {

	// MARK: - Internal

	init(entry: DiaryEntry) {
		switch entry {
		case .contactPerson(let contactPerson):
			text = contactPerson.name
		case .location(let location):
			text = location.name
		}
	}

	// MARK: - Internal

	let text: String

}
