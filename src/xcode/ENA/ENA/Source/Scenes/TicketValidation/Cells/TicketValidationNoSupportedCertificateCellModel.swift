//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIImage

final class TicketValidationNoSupportedCertificateCellModel {

	// MARK: - Init

	init(
		serviceProviderRequirementsDescription: String
	) {
		self.serviceProviderRequirementsDescription = serviceProviderRequirementsDescription
	}

	// MARK: - Internal

	let serviceProviderRequirementsDescription: String
	let iconImage = UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Failed")
}
