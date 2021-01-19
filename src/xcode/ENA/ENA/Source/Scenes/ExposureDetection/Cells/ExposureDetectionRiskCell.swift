//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureDetectionRiskCell: UITableViewCell {
	
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var separatorView: UIView!

	override func prepareForReuse() {
		super.prepareForReuse()
		stackView.forceLayoutUpdate()
		separatorView.isHidden = false
	}
}
