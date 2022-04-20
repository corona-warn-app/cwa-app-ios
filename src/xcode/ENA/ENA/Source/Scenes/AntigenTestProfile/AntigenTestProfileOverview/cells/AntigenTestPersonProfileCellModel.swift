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
		
		if let firstName = antigenTestProfile.firstName, let lastName = antigenTestProfile.lastName {
			name = "\(firstName) \(lastName)"
		} else if let firstName = antigenTestProfile.firstName {
			name = firstName
		} else if let lastName = antigenTestProfile.lastName {
			name = lastName
		} else {
			name = nil
		}

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
