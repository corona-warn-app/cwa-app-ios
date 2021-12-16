//
// 🦠 Corona-Warn-App
//

extension QRScannerCoordinator {
	private func showTicketValidationErrorAlert(error: TicketValidationError, serviceProvider: String) {
		let title: String
		if case .allowListError(.SP_ALLOWLIST_NO_MATCH) = error {
			title = AppStrings.TicketValidation.Error.serviceProviderErrorNoMatchTitle
		} else {
			title = AppStrings.TicketValidation.Error.title
		}
		
		let alert = UIAlertController(
			title: title,
			message: error.errorDescription(serviceProvider: serviceProvider),
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { [weak self] _ in
					self?.qrScannerViewController?.activateScanning()
				}
			)
		)
		
		if case .versionError = error {
			alert.addAction(
				UIAlertAction(
					title: AppStrings.TicketValidation.Error.updateApp,
					style: .default,
					handler: { _ in
						LinkHelper.open(urlString: "https://apps.apple.com/de/app/corona-warn-app/id1512595757?mt=8")
					}
				)
			)
		}

		DispatchQueue.main.async {
			self.qrScannerViewController?.present(alert, animated: true)
		}
	}

	// swiftlint:disable cyclomatic_complexity
	private func showQRCodeParserErrorAlert(error: QRCodeParserError) {
		let unwrappedError: Error
		switch error {
		case .scanningError(let qrScannerError):
			unwrappedError = qrScannerError
		case .checkinQrError(let checkinQRScannerError):
			unwrappedError = checkinQRScannerError
		case .certificateQrError(let healthCertificateServiceError):
			unwrappedError = healthCertificateServiceError
		case .ticketValidation(let ticketValidationError):
			unwrappedError = ticketValidationError
		}

		var alertTitle = AppStrings.HealthCertificate.Error.title
		var errorMessage = unwrappedError.localizedDescription
		var additionalActions = [UIAlertAction]()

		if case .certificateQrError(.invalidSignature) = error {
			// invalid signature error on certificates needs a specific title, errorMessage and FAQ action
			alertTitle = AppStrings.HealthCertificate.Error.invalidSignatureTitle
			errorMessage = unwrappedError.localizedDescription
			additionalActions.append(
				UIAlertAction(
					title: AppStrings.HealthCertificate.Error.invalidSignatureFAQButtonTitle,
					style: .default,
					handler: { [weak self] _ in
						if LinkHelper.open(urlString: AppStrings.Links.invalidSignatureFAQ) {
							self?.viewModel?.activateScanning()
						}
					}
				)
			)
		} else if case .certificateQrError(.tooManyPersonsRegistered) = error {
			// invalid signature error on certificates needs a specific title, errorMessage and FAQ action
			alertTitle = AppStrings.UniversalQRScanner.MaxPersonAmountAlert.errorTitle
			errorMessage = String(
				format: unwrappedError.localizedDescription,
				viewModel.dccPersonCountMax
			)
			additionalActions.append(contentsOf: [
				UIAlertAction(
					title: AppStrings.UniversalQRScanner.MaxPersonAmountAlert.covPassCheckButton,
					style: .default,
					handler: { [weak self] _ in
						if LinkHelper.open(urlString: AppStrings.UniversalQRScanner.MaxPersonAmountAlert.covPassCheckLink) {
							self?.viewModel?.activateScanning()
						}
					}
				),
				UIAlertAction(
					title: AppStrings.UniversalQRScanner.MaxPersonAmountAlert.faqButton,
					style: .default,
					handler: { [weak self] _ in
						if LinkHelper.open(urlString: AppStrings.UniversalQRScanner.MaxPersonAmountAlert.faqLink) {
							self?.viewModel?.activateScanning()
						}
					}
				)
			])
		} else if case .certificateQrError = error {
			// Show FAQ section for other certificate errors
			errorMessage += AppStrings.HealthCertificate.Error.faqDescription

			additionalActions.append(
				UIAlertAction(
					title: AppStrings.HealthCertificate.Error.faqButtonTitle,
					style: .default,
					handler: { [weak self] _ in
						if LinkHelper.open(urlString: AppStrings.Links.healthCertificateErrorFAQ) {
							self?.viewModel?.activateScanning()
						}
					}
				)
			)
		}

		let alert = UIAlertController(
			title: alertTitle,
			message: errorMessage,
			preferredStyle: .alert
		)

		additionalActions.forEach {
			alert.addAction($0)
		}
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { [weak self] _ in
					self?.viewModel?.activateScanning()
				}
			)
		)

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}

	private func showCameraPermissionErrorAlert() {
		let alert = UIAlertController(
			title: AppStrings.UniversalQRScanner.Error.CameraPermissionDenied.title,
			message: QRScannerError.cameraPermissionDenied.localizedDescription,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.UniversalQRScanner.Error.CameraPermissionDenied.settingsButton,
				style: .default,
				handler: { _ in
					LinkHelper.open(urlString: UIApplication.openSettingsURLString)
				}
			)
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionCancel,
				style: .cancel,
				handler: { [weak self] _ in
					self?.dismiss()
				}
			)
		)

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}
}
