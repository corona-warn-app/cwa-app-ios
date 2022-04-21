//
// 🦠 Corona-Warn-App
//

import UIKit
import OrderedCollections
import OpenCombine

class AntigenTestPersonProfileCellModel {
	
	// MARK: - Init

	init(
		antigenTestProfile: AntigenTestProfile
	) {
		backgroundGradientType = .blueOnly

		title = AppStrings.AntigenProfile.Overview.title
		
		name = antigenTestProfile.fullName

		qrCodeViewModel = QRCodeCellViewModel(
			antigenTestProfile: antigenTestProfile,
			backgroundColor: .enaColor(for: .background),
			borderColor: .enaColor(for: .hairline)
		)
	}

	// MARK: - Internal

	let backgroundGradientType: GradientView.GradientType
	
	let title: String
	let name: String?

	let qrCodeViewModel: QRCodeCellViewModel

}
