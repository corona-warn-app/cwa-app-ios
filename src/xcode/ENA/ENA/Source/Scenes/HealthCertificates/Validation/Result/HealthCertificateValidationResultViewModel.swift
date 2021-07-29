//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol HealthCertificateValidationResultViewModel {

	var title: String { get }
	var dynamicTableViewModel: DynamicTableViewModel { get }

}

extension HealthCertificateValidationResultViewModel {
	
	func sectionHeader(image: UIImage?) -> DynamicHeader {
		.image(
			image,
			accessibilityIdentifier: nil,
			height: 150,
			accessibilityTraits: .header,
			backgroundGradient: .whiteToLightBlue
		)
	}
}
