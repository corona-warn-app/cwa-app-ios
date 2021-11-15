//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct TicketValidationCertificateSelectionViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				separators: .none,
				cells: [
					.headline(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRequirementsHeadline),
					.headline(text: AppStrings.TicketValidation.CertificateSelection.serviceProviderRelevantCertificatesHeadline)
				]
			)
		])
	}

}
