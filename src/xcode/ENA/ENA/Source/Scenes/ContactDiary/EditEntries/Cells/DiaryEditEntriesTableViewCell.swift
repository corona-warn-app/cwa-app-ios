////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryEditEntriesTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(model: DiaryEditEntriesCellModel) {
		label.text = model.text
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!

}
