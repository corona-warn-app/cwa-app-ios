////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateOverviewDescriptionTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		descriptionLabel.text = AppStrings.HealthCertificate.Overview.description
	}

	// MARK: - Private

	@IBOutlet private weak var descriptionLabel: ENALabel!
    
}
