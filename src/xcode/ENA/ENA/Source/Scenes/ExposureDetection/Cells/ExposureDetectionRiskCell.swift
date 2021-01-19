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
		// hinding a stack views subview forces the stack view to update its layout
		// this is how we solve the layout bug when reusing stack views in table view cells
		stackView.forceLayoutUpdate()
		//
		separatorView.isHidden = false
	}
}
