////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateOverviewEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_Certificate_Empty")
	let title = AppStrings.HealthCertificate.Overview.emptyTitle
	let description = AppStrings.HealthCertificate.Overview.emptyDescription
	let imageDescription = AppStrings.HealthCertificate.Overview.emptyImageDescription

}
