////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestCertificateRequestCellModel {

	// MARK: - Init

	init(
		testCertificateRequest: TestCertificateRequest,
		onTryAgainButtonTap: @escaping () -> Void
	) {
		self.onTryAgainButtonTap = onTryAgainButtonTap

		title = AppStrings.HealthCertificate.Overview.TestCertificateRequest.title
		subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle
		registrationDate = String(
			format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.registrationDate,
			DateFormatter.localizedString(from: testCertificateRequest.registrationDate, dateStyle: .medium, timeStyle: .short)
		)

		loadingStateDescription = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingStateDescription
		buttonTitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.buttonTitle

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
	var buttonTitle: String

	@DidSetPublished var isTryAgainButtonHidden: Bool = true
	@DidSetPublished var isLoadingStateHidden: Bool = false

	func didTapButton() {
		onTryAgainButtonTap()
	}

	// MARK: - Private

	private let onTryAgainButtonTap: () -> Void
	private var subscriptions = Set<AnyCancellable>()

	private func updateLoadingState(isLoading: Bool) {
		if isLoading {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle
		} else {
			subtitle = AppStrings.HealthCertificate.Overview.TestCertificateRequest.errorSubtitle
		}

		isLoadingStateHidden = !isLoading
		isTryAgainButtonHidden = isLoading
	}

}
