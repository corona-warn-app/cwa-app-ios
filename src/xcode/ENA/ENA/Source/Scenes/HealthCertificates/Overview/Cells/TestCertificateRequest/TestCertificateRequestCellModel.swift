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

	let title: String
	let registrationDate: String
	let loadingStateDescription: String
	let tryAgainButtonTitle: String
	let removeButtonTitle: String

	@DidSetPublished var subtitle: String
	@DidSetPublished var isLoadingStateHidden: Bool = false
	@DidSetPublished var buttonsHidden: Bool = true

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private func updateLoadingState(isLoading: Bool) {
		guard !CWAHibernationProvider.shared.isHibernationState else {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.errorSubtitle
			isLoadingStateHidden = true
			buttonsHidden = false
			return
		}
		if isLoading {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle
		} else {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.errorSubtitle
		}

		isLoadingStateHidden = !isLoading
		buttonsHidden = isLoading
	}

}
