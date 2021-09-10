//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

// swiftlint:disable type_body_length
final class HealthCertificatesCoordinator {
	
	// MARK: - Init
	
	init(
		store: HealthCertificateStoring,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.store = store
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		#if DEBUG
		if isUITesting {
			store.healthCertificateInfoScreenShown = LaunchArguments.infoScreen.healthCertificateInfoScreenShown.boolValue
		}
		#endif

		setupCertificateBadgeCount()
	}
	
	// MARK: - Internal
	
	lazy var viewController: UINavigationController = {
		if !infoScreenShown {
			return UINavigationController(
				rootViewController: infoScreen(
					hidesCloseButton: true,
					dismissAction: { [weak self] in
						guard let self = self else { return }

						self.viewController.pushViewController(self.overviewScreen, animated: true)
						// Set Overview as the only Controller on the navigation stack to avoid back gesture etc.
						self.viewController.setViewControllers([self.overviewScreen], animated: false)

						self.infoScreenShown = true
					},
					showDetail: { detailViewController in
						self.viewController.pushViewController(detailViewController, animated: true)
					}
				)
			)
		} else {
			return UINavigationController(rootViewController: overviewScreen)
		}
	}()
	
	func showCertifiedPersonWithCertificateFromNotification(
		for healthCertifiedPerson: HealthCertifiedPerson,
		with healthCertificate: HealthCertificate
	) {
				
		showHealthCertificate(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			shouldPushOnModalNavigationController: false
		)
	}
	
	func showCertifiedPersonFromNotification(for healthCertifiedPerson: HealthCertifiedPerson) {
		showHealthCertifiedPerson(healthCertifiedPerson)
	}
	
	// MARK: - Private
	
	private let store: HealthCertificateStoring
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding

	private var modalNavigationController: UINavigationController!
	private var printNavigationController: UINavigationController!
	private var validationCoordinator: HealthCertificateValidationCoordinator?
	private var subscriptions = Set<AnyCancellable>()

	private var infoScreenShown: Bool {
		get { store.healthCertificateInfoScreenShown }
		set { store.healthCertificateInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: HealthCertificateOverviewViewController = {
		return HealthCertificateOverviewViewController(
			viewModel: HealthCertificateOverviewViewModel(
				healthCertificateService: healthCertificateService
			),
			onInfoBarButtonItemTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onCreateHealthCertificateTap: { [weak self] in
				guard let self = self else { return }

				self.showQRCodeScanner(from: self.viewController)
			},
			onCertifiedPersonTap: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPerson(healthCertifiedPerson)
			},
			onMissingPermissionsButtonTap: { [weak self] in
				self?.showSettings()
			}
		)
	}()

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> TopBottomContainerViewController<HealthCertificateInfoViewController, FooterViewController> {
		let consentScreen = HealthCertificateInfoViewController(
			viewModel: HealthCertificateInfoViewModel(
				hidesCloseButton: hidesCloseButton,
				didTapDataPrivacy: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false

					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}

					showDetail(detailViewController)
				}
			),
			dismiss: dismissAction
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Info.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: consentScreen,
			bottomController: footerViewController
		)
		return topBottomContainerViewController
	}

	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let infoVC = infoScreen(
			dismissAction: {
				navigationController.dismiss(animated: true)
			},
			showDetail: { detailViewController in
				navigationController.pushViewController(detailViewController, animated: true)
			}
		)
		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = UINavigationController(rootViewController: infoVC)
		viewController.present(navigationController, animated: true)
	}
	
	private func showQRCodeScanner(from presentingViewController: UIViewController) {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			healthCertificateService: healthCertificateService,
			didScanCertificate: { [weak self] healthCertifiedPerson, healthCertificate in
				presentingViewController.dismiss(animated: true) {
					if presentingViewController == self?.viewController {
						self?.showHealthCertificate(
							healthCertifiedPerson: healthCertifiedPerson,
							healthCertificate: healthCertificate,
							shouldPushOnModalNavigationController: false
						)
					}
				}
			},
			dismiss: {
				presentingViewController.dismiss(animated: true)
			}
		)

		qrCodeScannerViewController.definesPresentationContext = true
		let qrCodeNavigationController = UINavigationController(rootViewController: qrCodeScannerViewController)
		qrCodeNavigationController.modalPresentationStyle = .fullScreen

		presentingViewController.present(qrCodeNavigationController, animated: true)
	}
	
	private func showHealthCertifiedPerson(
		_ healthCertifiedPerson: HealthCertifiedPerson
	) {
		let healthCertificatePersonViewController = HealthCertifiedPersonViewController(
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			},
			didTapValidationButton: { [weak self] healthCertificate, setLoadingState in
				setLoadingState(true)

				self?.healthCertificateValidationOnboardedCountriesProvider.onboardedCountries { result in
					setLoadingState(false)

					switch result {
					case .success(let countries):
						self?.showValidationFlow(
							healthCertificate: healthCertificate,
							countries: countries
						)
					case .failure(let error):
						self?.showErrorAlert(
							title: AppStrings.HealthCertificate.Validation.Error.title,
							error: error
						)
					}
				}
			},
			didTapHealthCertificate: { [weak self] healthCertificate in
				self?.showHealthCertificate(
					healthCertifiedPerson: healthCertifiedPerson,
					healthCertificate: healthCertificate,
					shouldPushOnModalNavigationController: true
				)
			},
			didSwipeToDelete: { [weak self] healthCertificate, confirmDeletion in
				self?.showDeleteAlert(
					certificateType: healthCertificate.type,
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .destructive,
						handler: { _ in
							guard let self = self else {
								Log.error("Could not create strong self")
								return
							}
							self.healthCertificateService.removeHealthCertificate(healthCertificate)
							// Do not confirm deletion if we removed the last certificate of the person (this removes the person, too) because it would trigger a new reload of the table where no person can be shown. Instead, we dismiss the view controller.
							if self.healthCertificateService.healthCertifiedPersons.value.contains(healthCertifiedPerson) {
								confirmDeletion()
							} else {
								self.viewController.dismiss(animated: true)
							}
						}
					)
				)
			}
		)
		modalNavigationController = UINavigationController(rootViewController: healthCertificatePersonViewController)
		viewController.present(modalNavigationController, animated: true)
	}
	
	private func showHealthCertificate(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		shouldPushOnModalNavigationController: Bool
	) {
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Details.validationButtonTitle,
			secondaryButtonName: AppStrings.HealthCertificate.Details.moreButtonTitle,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: true,
			isSecondaryButtonHidden: false,
			primaryButtonInverted: false,
			secondaryButtonInverted: true,
			backgroundColor: .enaColor(for: .cellBackground)
		)

		let footerViewController = FooterViewController(footerViewModel)

		let healthCertificateViewController = HealthCertificateViewController(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			},
			didTapValidationButton: { [weak self] in
				footerViewModel.setLoadingIndicator(true, disable: true, button: .primary)
				footerViewModel.setLoadingIndicator(false, disable: true, button: .secondary)

				self?.healthCertificateValidationOnboardedCountriesProvider.onboardedCountries { result in
					footerViewModel.setLoadingIndicator(false, disable: false, button: .primary)
					footerViewModel.setLoadingIndicator(false, disable: false, button: .secondary)

					switch result {
					case .success(let countries):
						self?.showValidationFlow(
							healthCertificate: healthCertificate,
							countries: countries
						)
					case .failure(let error):
						self?.showErrorAlert(
							title: AppStrings.HealthCertificate.Validation.Error.title,
							error: error
						)
					}
				}
			},
			didTapMoreButton: { [weak self] in
				self?.showActionSheet(
					healthCertificate: healthCertificate,
					removeAction: { [weak self] in
						// pass this as closure instead of passing several properties to showActionSheet().
						self?.showDeleteAlert(
							certificateType: healthCertificate.type,
							submitAction: UIAlertAction(
								title: AppStrings.HealthCertificate.Alert.deleteButton,
								style: .destructive,
								handler: { _ in
									guard let self = self else {
										Log.error("Could not create strong self")
										return
									}
									self.healthCertificateService.removeHealthCertificate(healthCertificate)
									let isPersonStillExistent = self.healthCertificateService.healthCertifiedPersons.value.contains(healthCertifiedPerson)

									// Only pop to root if we did not removed the last certificate of a person (because this removes the person, too). A pop would trigger a reload of content which was removed before. If so, dismiss to go back to certificate overview.
									if shouldPushOnModalNavigationController && isPersonStillExistent {
										self.modalNavigationController.popToRootViewController(animated: true)
									} else {
										self.modalNavigationController.dismiss(animated: true)
									}
								}
							)
						)
					}
				)
			}
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)

		if shouldPushOnModalNavigationController {
			modalNavigationController.pushViewController(topBottomContainerViewController, animated: true)
		} else {
			modalNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
			viewController.present(self.modalNavigationController, animated: true)
		}
	}

	private func showValidationFlow(
		healthCertificate: HealthCertificate,
		countries: [Country]
	) {
		validationCoordinator = HealthCertificateValidationCoordinator(
			parentViewController: modalNavigationController,
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			healthCertificateValidationService: healthCertificateValidationService,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)

		validationCoordinator?.start()
	}
	
	private func showActionSheet(
		healthCertificate: HealthCertificate,
		removeAction: @escaping () -> Void
	) {
		let actionSheet = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		let printAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.showVersion,
			style: .default,
			handler: { [weak self] _ in
				// Check first if the certificate is obtained in DE. If not, show error alert.
				guard healthCertificate.cborWebTokenHeader.issuer == "DE" else {
					self?.showPdfPrintErrorAlert()
					return
				}
				self?.showPdfGenerationInfo(
					healthCertificate: healthCertificate
				)
			}
		)
		actionSheet.addAction(printAction)

		let deleteButtonTitle: String
		switch healthCertificate.type {
		case .vaccination:
			deleteButtonTitle = AppStrings.HealthCertificate.Details.deleteButtonTitle
		case .test:
			deleteButtonTitle = AppStrings.HealthCertificate.Details.TestCertificate.primaryButton
		case .recovery:
			deleteButtonTitle = AppStrings.HealthCertificate.Details.RecoveryCertificate.primaryButton
		}
		
		let removeAction = UIAlertAction(
			title: deleteButtonTitle,
			style: .destructive,
			handler: { _ in
				removeAction()
			}
		)
		actionSheet.addAction(removeAction)
		
		let cancelAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.cancel,
			style: .cancel,
			handler: nil
		)
		actionSheet.addAction(cancelAction)
		modalNavigationController.present(actionSheet, animated: true, completion: nil)
	}
	
	private func showDeleteAlert(
		certificateType: HealthCertificate.CertificateType,
		submitAction: UIAlertAction
	) {
		let title: String
		let message: String

		switch certificateType {
		case .vaccination:
			title = AppStrings.HealthCertificate.Alert.VaccinationCertificate.title
			message = AppStrings.HealthCertificate.Alert.VaccinationCertificate.message
		case .test:
			title = AppStrings.HealthCertificate.Alert.TestCertificate.title
			message = AppStrings.HealthCertificate.Alert.TestCertificate.message
		case .recovery:
			title = AppStrings.HealthCertificate.Alert.RecoveryCertificate.title
			message = AppStrings.HealthCertificate.Alert.RecoveryCertificate.message
		}

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Alert.cancelButton,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)
		modalNavigationController.present(alert, animated: true)
	}
	
	private func showPdfGenerationInfo(
		healthCertificate: HealthCertificate
	) {
		let healthCertificatePDFGenerationInfoViewController = HealthCertificatePDFGenerationInfoViewController(
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			onTapContinue: { [weak self] pdfDocument in
				self?.showPdfGenerationResult(
					healthCertificate: healthCertificate,
					pdfDocument: pdfDocument
				)
			},
			onDismiss: { [weak self] in
				self?.modalNavigationController.dismiss(animated: true)
			},
			showErrorAlert: { [weak self] error in
				self?.showErrorAlert(
					title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.fetchValueSets.title,
					error: error
				)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.PrintPDF.Info.primaryButton,
				primaryIdentifier: AccessibilityIdentifiers.HealthCertificate.PrintPdf.infoPrimaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificatePDFGenerationInfoViewController,
			bottomController: footerViewController
		)
		
		printNavigationController = DismissHandlingNavigationController(
			rootViewController: topBottomContainerViewController,
			transparent: true
		)
		modalNavigationController.present(printNavigationController, animated: true)
	}
	
	private func showPdfGenerationResult(
		healthCertificate: HealthCertificate,
		pdfDocument: PDFDocument
	) {
		let healthCertificatePDFVersionViewModel = HealthCertificatePDFVersionViewModel(
			healthCertificate: healthCertificate,
			pdfDocument: pdfDocument
		)
		
		let healthCertificatePDFVersionViewController = HealthCertificatePDFVersionViewController(
			viewModel: healthCertificatePDFVersionViewModel,
			onTapPrintPdf: printPdf,
			onTapExportPdf: exportPdf
		)
		printNavigationController.pushViewController(healthCertificatePDFVersionViewController, animated: true)
	}
	
	private func printPdf(
		pdfData: Data
	) {
		let printController = UIPrintInteractionController.shared
		printController.printingItem = pdfData
		printController.present(animated: true, completionHandler: nil)
	}
	
	private func exportPdf(
		exportItem: PDFExportItem
	) {
		let activityViewController = UIActivityViewController(activityItems: [exportItem], applicationActivities: nil)
		printNavigationController.present(activityViewController, animated: true, completion: nil)
	}

	private func showErrorAlert(
		title: String,
		error: Error
	) {
		let alert = UIAlertController(
			title: title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		let okayAction = UIAlertAction(
			title: AppStrings.Common.alertActionOk,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)
		alert.addAction(okayAction)
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {
				fatalError("Could not create strong self")
			}
			
			if self.modalNavigationController.isBeingPresented {
				self.modalNavigationController.present(alert, animated: true, completion: nil)
			} else {
				self.printNavigationController.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	private func showPdfPrintErrorAlert() {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.title,
			message: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.message,
			preferredStyle: .alert
		)
		
		let faqAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.faq,
			style: .default,
			handler: { _ in
				LinkHelper.open(urlString: AppStrings.Links.healthCertificatePrintFAQ)
			}
		)
		faqAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.faqAction
		alert.addAction(faqAction)
		
		let okayAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.ok,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)
		okayAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.okAction
		alert.addAction(okayAction)

		modalNavigationController.present(alert, animated: true, completion: nil)
	}

	private func setupCertificateBadgeCount() {
		healthCertificateService.unseenNewsCount
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.viewController.tabBarItem.badgeValue = $0 > 0 ? String($0) : nil
			}
			.store(in: &subscriptions)
	}
	
	private func showSettings() {
		LinkHelper.open(urlString: UIApplication.openSettingsURLString)
	}

	// swiftlint:disable file_length
}
