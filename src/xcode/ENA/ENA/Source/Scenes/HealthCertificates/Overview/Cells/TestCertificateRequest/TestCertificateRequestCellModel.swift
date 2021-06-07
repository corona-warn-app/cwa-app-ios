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
		subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle
		registrationDate = String(
			format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.registrationDate,
			DateFormatter.localizedString(from: testCertificateRequest.registrationDate, dateStyle: .medium, timeStyle: .short)
		)

		loadingStateDescription = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingStateDescription
		tryAgainButtonTitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.tryAgainButtonTitle
		removeButtonTitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.removeButtonTitle

		updateLoadingState(isLoading: testCertificateRequest.isLoading)

		testCertificateRequest.objectDidChange
			.sink { [weak self] in
				self?.updateLoadingState(isLoading: $0.isLoading)
			}
			.store(in: &subscriptions)
	}
	
	// MARK: - Internal

	var title: String
	@DidSetPublished var subtitle: String
	var registrationDate: String

	var loadingStateDescription: String
	var tryAgainButtonTitle: String
	var removeButtonTitle: String

	@DidSetPublished var isLoadingStateHidden: Bool = false
	@DidSetPublished var buttonsHidden: Bool = true

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private func updateLoadingState(isLoading: Bool) {
		if isLoading {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle
		} else {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.errorSubtitle
		}

		isLoadingStateHidden = !isLoading
		buttonsHidden = isLoading
	}

}
