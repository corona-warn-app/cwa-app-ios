//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureDetectionRiskCell: UITableViewCell {
	@IBOutlet var separatorView: UIView!

	override func prepareForReuse() {
		super.prepareForReuse()

		separatorView.isHidden = false
	}
}
