////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryOverviewDescriptionTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		descriptionLabel.text = AppStrings.ContactDiary.Overview.description
	}

	// MARK: - Private

	@IBOutlet private weak var descriptionLabel: ENALabel!
    
}
