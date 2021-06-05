////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestCertificateRequestCellModel {

	// MARK: - Init

	init(
		testCertificateRequest: TestCertificateRequest
	) {
		title = AppStrings.HealthCertificate.Overview.TestCertificateRequest.title
		subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.subtitle
		registrationDate = String(
			format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.registrationDate,
			DateFormatter.localizedString(from: testCertificateRequest.registrationDate, dateStyle: .medium, timeStyle: .short)
		)

		loadingStateDescription = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingStateDescription
		buttonTitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.buttonTitle

		isLoadingStateHidden = testCertificateRequest.requestExecutionFailed
		isButtonHidden = !testCertificateRequest.requestExecutionFailed

		// TODO: Reload on button tap
	}
	
	// MARK: - Internal

	var title: String
	var subtitle: String
	var registrationDate: String

	var loadingStateDescription: String
	var buttonTitle: String

	var isButtonHidden: Bool
	var isLoadingStateHidden: Bool

}
